# Ativa o carregamento local (local_infile) no servidor MySQL, sem precisar do cliente "mysql".
# Uso:  python ativar_local_infile.py
import getpass
import pymysql

host = input("Host [localhost]: ").strip() or "localhost"
usuario = input("Usuário [root]: ").strip() or "root"
senha = getpass.getpass("Senha (não aparece ao digitar): ")

con = pymysql.connect(host=host, user=usuario, password=senha)
cur = con.cursor()
cur.execute("SET GLOBAL local_infile = 1")
cur.execute("SHOW GLOBAL VARIABLES LIKE 'local_infile'")
print("Resultado:", cur.fetchall())
con.close()
print("Se apareceu ('local_infile', 'ON'), pode rodar o importar_mysql.py.")