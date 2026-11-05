CREATE TABLE IF NOT EXISTS dim_uf (
  sigla CHAR(2) NOT NULL,
  cod_ibge CHAR(2) NOT NULL,
  nome VARCHAR(30) NOT NULL,
  regiao VARCHAR(15) NOT NULL,
  PRIMARY KEY (sigla)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS dim_natureza_juridica (
  cod CHAR(4) NOT NULL,
  descricao VARCHAR(60) NOT NULL,
  PRIMARY KEY (cod)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS dim_municipio (
  cd_municipio CHAR(7) NOT NULL,
  nome VARCHAR(40) NULL,
  uf CHAR(2) NOT NULL,
  PRIMARY KEY (cd_municipio),
  CONSTRAINT fk_mun_uf FOREIGN KEY (uf) REFERENCES dim_uf (sigla),
  KEY idx_mun_uf (uf)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS osc (
  cnpj CHAR(14) NOT NULL COMMENT 'CNPJ completo, 14 dígitos (chave primária)',
  cnpj_basico CHAR(8) NOT NULL COMMENT 'Raiz do CNPJ (identifica a entidade; matriz e filiais compartilham)',
  cnpj_ordem CHAR(4) NOT NULL COMMENT 'Ordem do estabelecimento no CNPJ (0001 = matriz)',
  razao_social VARCHAR(220) NOT NULL COMMENT 'Razão social padronizada (maiúsculas, sem espaços extras)',
  nome_fantasia VARCHAR(140) NULL COMMENT 'Nome fantasia; NULL quando não informado',
  natureza_juridica_cod CHAR(4) NULL COMMENT 'Código da natureza jurídica (FK dim_natureza_juridica); NULL = não informada',
  tipo_estabelecimento VARCHAR(7) NOT NULL COMMENT 'Matriz ou Filial (derivado da ordem do CNPJ quando não informado)',
  situacao_cadastral VARCHAR(15) NOT NULL COMMENT 'Ativa, Inapta, Suspensa ou Nula ou Baixada',
  removida_do_mosc TINYINT(1) NOT NULL COMMENT '1 = removida do MOSC',
  dt_fundacao DATE NULL COMMENT 'Data de fundação; NULL quando ausente',
  ano_fundacao SMALLINT NULL COMMENT 'Ano da data de fundação',
  dt_fechamento DATE NULL COMMENT 'Data de fechamento/saída do cadastro (existe só para parte das baixadas)',
  ano_fechamento SMALLINT NULL COMMENT 'Ano da data de fechamento',
  endereco_completo VARCHAR(290) NULL COMMENT 'Endereço padronizado',
  cd_municipio CHAR(7) NULL COMMENT 'Código IBGE do município (FK dim_municipio); NULL quando inválido',
  uf CHAR(2) NULL COMMENT 'Sigla da UF (FK dim_uf); imputada pelo código IBGE quando ausente',
  latitude DECIMAL(9,6) NULL COMMENT 'Latitude em graus decimais (6 casas, ~0,1 m)',
  longitude DECIMAL(9,6) NULL COMMENT 'Longitude em graus decimais (6 casas, ~0,1 m)',
  cnae CHAR(5) NULL COMMENT 'CNAE principal (5 dígitos); NULL quando ausente ou inválido',
  n_cnae_sec SMALLINT NOT NULL COMMENT 'Nº de CNAEs secundários distintos (valor original)',
  n_cnae_sec_aj SMALLINT NOT NULL COMMENT 'Nº de CNAEs secundários com teto no percentil 99,9',
  sem_classificacao_area TINYINT(1) NOT NULL COMMENT '1 = OSC sem classificação de área/subárea na origem (flags preenchidas com 0)',
  area_assistencia_social TINYINT(1) NOT NULL COMMENT 'Atua em Assistência social (1/0)',
  area_assoc_patronais_profissionais TINYINT(1) NOT NULL COMMENT 'Atua em Associações patronais e profissionais (1/0)',
  area_cultura_recreacao TINYINT(1) NOT NULL COMMENT 'Atua em Cultura e recreação (1/0)',
  area_desenv_defesa_direitos TINYINT(1) NOT NULL COMMENT 'Atua em Desenvolvimento e defesa de direitos e interesses (1/0)',
  area_educacao_pesquisa TINYINT(1) NOT NULL COMMENT 'Atua em Educação e pesquisa (1/0)',
  area_outras_ativ_associativas TINYINT(1) NOT NULL COMMENT 'Atua em Outras atividades associativas (1/0)',
  area_religiao TINYINT(1) NOT NULL COMMENT 'Atua em Religião (1/0)',
  area_saude TINYINT(1) NOT NULL COMMENT 'Atua em Saúde (1/0)',
  sub_assistencia_social TINYINT(1) NOT NULL COMMENT 'Subárea Assistência social (1/0)',
  sub_assoc_nao_especificadas TINYINT(1) NOT NULL COMMENT 'Subárea Associações de atividades não especificadas anteriormente (1/0)',
  sub_produtores_rurais_pescadores TINYINT(1) NOT NULL COMMENT 'Subárea Associações de produtores rurais, pescadores e similares (1/0)',
  sub_empresariais_patronais TINYINT(1) NOT NULL COMMENT 'Subárea Associações empresariais e patronais (1/0)',
  sub_profissionais TINYINT(1) NOT NULL COMMENT 'Subárea Associações profissionais (1/0)',
  sub_apoio_educacao TINYINT(1) NOT NULL COMMENT 'Subárea Atividades de apoio à educação (1/0)',
  sub_cultura_arte TINYINT(1) NOT NULL COMMENT 'Subárea Cultura e arte (1/0)',
  sub_desenv_defesa_direitos TINYINT(1) NOT NULL COMMENT 'Subárea Desenvolvimento e defesa de direitos (1/0)',
  sub_educacao_infantil TINYINT(1) NOT NULL COMMENT 'Subárea Educação infantil (1/0)',
  sub_educacao_profissional TINYINT(1) NOT NULL COMMENT 'Subárea Educação profissional (1/0)',
  sub_ensino_fundamental TINYINT(1) NOT NULL COMMENT 'Subárea Ensino fundamental (1/0)',
  sub_ensino_superior TINYINT(1) NOT NULL COMMENT 'Subárea Ensino superior (1/0)',
  sub_esportes_recreacao TINYINT(1) NOT NULL COMMENT 'Subárea Esportes e recreação (1/0)',
  sub_estudos_pesquisas TINYINT(1) NOT NULL COMMENT 'Subárea Estudos e pesquisas (1/0)',
  sub_hospitais TINYINT(1) NOT NULL COMMENT 'Subárea Hospitais (1/0)',
  sub_outras_formas_educacao TINYINT(1) NOT NULL COMMENT 'Subárea Outras formas de educação e ensino (1/0)',
  sub_outros_servicos_saude TINYINT(1) NOT NULL COMMENT 'Subárea Outros serviços de saúde (1/0)',
  sub_religiao TINYINT(1) NOT NULL COMMENT 'Subárea Religião (1/0)',
  flag_uf_imputada TINYINT(1) NOT NULL COMMENT '1 = UF recuperada pelo código IBGE',
  flag_tipo_estab_derivado TINYINT(1) NOT NULL COMMENT '1 = matriz/filial derivado do CNPJ',
  flag_tipo_estab_incoerente TINYINT(1) NOT NULL COMMENT '1 = matriz/filial informado contradiz a ordem do CNPJ',
  flag_fechamento_antes_fundacao TINYINT(1) NOT NULL COMMENT '1 = data de fechamento anterior à fundação',
  flag_cnae_invalido TINYINT(1) NOT NULL COMMENT '1 = CNAE original fora do padrão (virou NULL)',
  flag_coord_ajustada TINYINT(1) NOT NULL COMMENT '1 = coordenada suspeita substituída pela mediana do município',
  flag_coord_ausente TINYINT(1) NOT NULL COMMENT '1 = OSC sem coordenadas',
  flag_possivel_duplicidade TINYINT(1) NOT NULL COMMENT '1 = possível duplicidade cadastral (ver dup_grupo_id)',
  dup_grupo_id INT NULL COMMENT 'Identificador do grupo de possíveis duplicatas',
  flag_outlier_n_cnae_sec TINYINT(1) NOT NULL COMMENT '1 = nº de CNAEs secundários acima do percentil 99,9',
  flag_outlier_ano_fundacao TINYINT(1) NOT NULL COMMENT '1 = ano de fundação abaixo da cerca de Tukey',
  PRIMARY KEY (cnpj),
  CONSTRAINT fk_osc_natureza FOREIGN KEY (natureza_juridica_cod) REFERENCES dim_natureza_juridica (cod),
  CONSTRAINT fk_osc_municipio FOREIGN KEY (cd_municipio) REFERENCES dim_municipio (cd_municipio),
  CONSTRAINT fk_osc_uf FOREIGN KEY (uf) REFERENCES dim_uf (sigla),
  KEY idx_osc_basico (cnpj_basico),
  KEY idx_osc_uf (uf),
  KEY idx_osc_municipio (cd_municipio),
  KEY idx_osc_situacao (situacao_cadastral),
  KEY idx_osc_natureza (natureza_juridica_cod),
  KEY idx_osc_cnae (cnae),
  KEY idx_osc_ano_fund (ano_fundacao)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS osc_cnae_secundario (
  cnpj CHAR(14) NOT NULL,
  cnae CHAR(7) NOT NULL,
  PRIMARY KEY (cnpj, cnae),
  CONSTRAINT fk_sec_osc FOREIGN KEY (cnpj) REFERENCES osc (cnpj) ON DELETE CASCADE,
  KEY idx_sec_cnae (cnae)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS aud_coordenada_ajustada (
  cnpj CHAR(14) NOT NULL,
  latitude_original DECIMAL(9,6) NOT NULL,
  longitude_original DECIMAL(9,6) NOT NULL,
  latitude_nova DECIMAL(9,6) NOT NULL,
  longitude_nova DECIMAL(9,6) NOT NULL,
  distancia_graus DECIMAL(7,3) NOT NULL,
  PRIMARY KEY (cnpj),
  CONSTRAINT fk_aud_osc FOREIGN KEY (cnpj) REFERENCES osc (cnpj) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS log_tratamento (
  id INT NOT NULL AUTO_INCREMENT,
  etapa VARCHAR(30) NOT NULL,
  regra VARCHAR(250) NOT NULL,
  coluna VARCHAR(80) NOT NULL,
  registros_afetados INT NOT NULL,
  acao VARCHAR(250) NOT NULL,
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
