#!/usr/bin/env python3
# Importa a base tratada do MOSC para o MySQL 8.x (ou MariaDB 10.x).
#
# Preparação (uma vez):
#   pip install pymysql
#   no servidor:  SET GLOBAL local_infile = 1;      (necessário para o LOAD DATA LOCAL)
#
# Uso:
#   python importar_mysql.py --host localhost --user root --password SUA_SENHA --database mosc --pasta saida_tratamento --recriar
import argparse, csv, gzip, os, shutil, sys, time
import pymysql

ORDEM = [
    ("dim_uf", "dim_uf.csv"),
    ("dim_natureza_juridica", "dim_natureza_juridica.csv"),
    ("dim_municipio", "dim_municipio.csv"),
    ("osc", "MOSC_tratada.csv"),
    ("osc_cnae_secundario", "osc_cnae_secundario.csv"),
    ("aud_coordenada_ajustada", "aud_coordenada_ajustada.csv"),
    ("log_tratamento", "log_tratamento.csv"),
]


def garantir_csv(caminho):
    # o LOAD DATA não lê .gz: se só existir o .csv.gz, descompacta ao lado
    if not os.path.exists(caminho) and os.path.exists(caminho + ".gz"):
        print(f"  descompactando {caminho}.gz ...")
        with gzip.open(caminho + ".gz", "rb") as f_in, open(caminho, "wb") as f_out:
            shutil.copyfileobj(f_in, f_out)
    if not os.path.exists(caminho):
        sys.exit(f"Arquivo não encontrado: {caminho}")
    return caminho


def comandos_do_schema(caminho):
    with open(caminho, encoding="utf-8") as f:
        texto = f.read()
    return [c.strip() for c in texto.split(";\n") if c.strip()]


def carregar(cur, tabela, caminho):
    with open(caminho, encoding="utf-8", newline="") as f:
        leitor = csv.reader(f)
        cabecalho = next(leitor)
        n_csv = sum(1 for _ in leitor)

    cur.execute(f"SHOW COLUMNS FROM `{tabela}`")
    colunas_tabela = {linha[0] for linha in cur.fetchall()}

    variaveis, atribuicoes, descartadas = [], [], []
    for i, col in enumerate(cabecalho):
        variaveis.append(f"@v{i}")
        if col in colunas_tabela:
            atribuicoes.append(f"`{col}` = NULLIF(@v{i}, '')")   # texto vazio vira NULL
        else:
            descartadas.append(col)                               # coluna extra do CSV (rótulos): ignorada

    caminho_sql = os.path.abspath(caminho).replace("\\", "/").replace("'", "''")
    sql = (
        f"LOAD DATA LOCAL INFILE '{caminho_sql}' INTO TABLE `{tabela}` CHARACTER SET utf8mb4 "
        "FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '\"' ESCAPED BY '' "
        "LINES TERMINATED BY '\\n' IGNORE 1 LINES "
        f"({', '.join(variaveis)}) SET {', '.join(atribuicoes)}"
    )
    t0 = time.time()
    cur.execute(sql)
    cur.execute(f"SELECT COUNT(*) FROM `{tabela}`")
    n_db = cur.fetchone()[0]
    status = "OK" if n_db == n_csv else "DIVERGENTE"
    extra = f" | colunas ignoradas: {', '.join(descartadas)}" if descartadas else ""
    print(f"  {tabela:<26}{n_csv:>10,} linhas no CSV | {n_db:>10,} na tabela | {status} | {time.time() - t0:.1f}s{extra}")
    cur.execute("SHOW WARNINGS")
    avisos = cur.fetchall()
    if avisos:
        print(f"    {len(avisos)} aviso(s); primeiro: {avisos[0]}")
    return n_db == n_csv


def main():
    ap = argparse.ArgumentParser(description="Importa a base tratada do MOSC para o MySQL")
    ap.add_argument("--host", default="localhost")
    ap.add_argument("--port", type=int, default=3306)
    ap.add_argument("--user", default="root")
    ap.add_argument("--password", default="")
    ap.add_argument("--database", default="mosc")
    ap.add_argument("--pasta", default="saida_tratamento", help="pasta com os CSVs e o schema.sql")
    ap.add_argument("--recriar", action="store_true", help="apaga o banco antes de criar (CUIDADO)")
    args = ap.parse_args()

    con = pymysql.connect(host=args.host, port=args.port, user=args.user, password=args.password,
                          charset="utf8mb4", local_infile=True, autocommit=True)
    cur = con.cursor()
    if args.recriar:
        cur.execute(f"DROP DATABASE IF EXISTS `{args.database}`")
    cur.execute(f"CREATE DATABASE IF NOT EXISTS `{args.database}` CHARACTER SET utf8mb4")
    cur.execute(f"USE `{args.database}`")

    print("Criando tabelas (schema.sql) ...")
    for comando in comandos_do_schema(os.path.join(args.pasta, "schema.sql")):
        cur.execute(comando)

    print("Carregando dados ...")
    tudo_ok = True
    for tabela, arquivo in ORDEM:
        caminho = garantir_csv(os.path.join(args.pasta, arquivo))
        try:
            tudo_ok &= carregar(cur, tabela, caminho)
        except pymysql.err.OperationalError as e:
            if e.args and e.args[0] in (1148, 3948):
                sys.exit("O servidor bloqueou LOAD DATA LOCAL. Rode no MySQL:  SET GLOBAL local_infile = 1;  e tente de novo.")
            raise

    print("\nVerificações de integridade:")
    consultas = {
        "OSCs sem UF válida (órfãs)": "SELECT COUNT(*) FROM osc o LEFT JOIN dim_uf u ON u.sigla = o.uf WHERE o.uf IS NOT NULL AND u.sigla IS NULL",
        "OSCs sem município válido (órfãs)": "SELECT COUNT(*) FROM osc o LEFT JOIN dim_municipio m ON m.cd_municipio = o.cd_municipio WHERE o.cd_municipio IS NOT NULL AND m.cd_municipio IS NULL",
        "CNAEs secundários sem OSC (órfãos)": "SELECT COUNT(*) FROM osc_cnae_secundario s LEFT JOIN osc o ON o.cnpj = s.cnpj WHERE o.cnpj IS NULL",
    }
    for nome, sql in consultas.items():
        cur.execute(sql)
        print(f"  {nome:<40}{cur.fetchone()[0]}")
    print("\nConcluído." if tudo_ok else "\nConcluído com divergências: revise as linhas marcadas acima.")
    con.close()


if __name__ == "__main__":
    main()
