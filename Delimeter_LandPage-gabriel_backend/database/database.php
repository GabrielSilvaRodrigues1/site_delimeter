<?php

// Conecta-se ao banco de dados
$db = new SQLite3('database.db');

// Define a estrutura da tabela
$sql = "CREATE TABLE usuario (
    id_usuario INTEGER PRIMARY KEY AUTOINCREMENT,
    nome_usuario TEXT NOT NULL,
    email_usuario TEXT UNIQUE,
    senha_usuario TEXT NOT NULL
);
CREATE TABLE endereco_usuario (
    id_endereco INTEGER PRIMARY KEY AUTOINCREMENT,
    id_usuario INTEGER NOT NULL,
    endereco TEXT NOT NULL,
    FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario)
);
CREATE TABLE telefone_usuario (
    id_telefone INTEGER PRIMARY KEY AUTOINCREMENT,
    id_usuario INTEGER NOT NULL,
    telefone TEXT NOT NULL,
    FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario)
);
CREATE TABLE medico (
    id_medico INTEGER PRIMARY KEY AUTOINCREMENT,
    id_usuario INTEGER NOT NULL,
    crm_medico TEXT,
    FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario)
);

CREATE TABLE nutricionista (
    id_nutricionista INTEGER PRIMARY KEY AUTOINCREMENT,
    id_usuario INTEGER NOT NULL,
    crm_nutricionista TEXT,
    FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario)
);

CREATE TABLE paciente (
    id_paciente INTEGER PRIMARY KEY AUTOINCREMENT,
    id_usuario INTEGER NOT NULL,
    cpf TEXT UNIQUE,
    nis TEXT UNIQUE,
    FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario)
);
CREATE TABLE dados_antropometricos (
    id_medida INTEGER PRIMARY KEY AUTOINCREMENT,
    id_paciente INTEGER NOT NULL,
    sexo_paciente INTEGER,
    altura_paciente REAL,
    peso_paciente REAL,
    status_paciente INTEGER,
    data_medida DATE,
    FOREIGN KEY (id_paciente) REFERENCES paciente(id_paciente)
);
CREATE TABLE dieta (
    id_dieta INTEGER PRIMARY KEY AUTOINCREMENT,
    data_inicio_dieta DATE,
    data_termino_dieta DATE,
    descricao_dieta TEXT
);
CREATE TABLE alimento (
    id_alimento INTEGER PRIMARY KEY AUTOINCREMENT,
    descricao_alimento TEXT,
    dados_nutricionais TEXT
);
CREATE TABLE diario_de_alimentos (
    id_diario INTEGER PRIMARY KEY AUTOINCREMENT,
    id_paciente INTEGER,
    data_diario DATE,
    descricao_diario TEXT,
    FOREIGN KEY (id_paciente) REFERENCES paciente(id_paciente)
);
CREATE TABLE receita (
    id_receita INTEGER PRIMARY KEY AUTOINCREMENT,
    data_inicio_receita DATE,
    data_termino_receita DATE,
    descricao_receita TEXT
);
CREATE TABLE consulta (
    id_consulta INTEGER PRIMARY KEY AUTOINCREMENT,
    data_consulta DATE
);
CREATE TABLE historico_clinico (
    id_historico_clinico INTEGER PRIMARY KEY AUTOINCREMENT,
    id_paciente INTEGER,
    id_receita INTEGER,
    id_dieta INTEGER,
    FOREIGN KEY (id_paciente) REFERENCES paciente(id_paciente),
    FOREIGN KEY (id_receita) REFERENCES receita(id_receita),
    FOREIGN KEY (id_dieta) REFERENCES dieta(id_dieta)
);
CREATE TABLE relacao_diario_alimento (
    id_alimento INTEGER,
    id_diario INTEGER,
    PRIMARY KEY (id_alimento, id_diario),
    FOREIGN KEY (id_alimento) REFERENCES alimento(id_alimento),
    FOREIGN KEY (id_diario) REFERENCES diario_de_alimentos(id_diario)
);
CREATE TABLE relacao_alimento_dieta (
    id_alimento INTEGER,
    id_dieta INTEGER,
    PRIMARY KEY (id_alimento, id_dieta),
    FOREIGN KEY (id_alimento) REFERENCES alimento(id_alimento),
    FOREIGN KEY (id_dieta) REFERENCES dieta(id_dieta)
);
CREATE TABLE relacao_nutricionista_dieta (
    id_dieta INTEGER,
    id_nutricionista INTEGER,
    PRIMARY KEY (id_dieta, id_nutricionista),
    FOREIGN KEY (id_dieta) REFERENCES dieta(id_dieta),
    FOREIGN KEY (id_nutricionista) REFERENCES nutricionista(id_nutricionista)
);
CREATE TABLE valida_medidas_nutricionista (
    id_medida INTEGER,
    id_nutricionista INTEGER,
    PRIMARY KEY (id_medida, id_nutricionista),
    FOREIGN KEY (id_medida) REFERENCES dados_antropometricos(id_medida),
    FOREIGN KEY (id_nutricionista) REFERENCES nutricionista(id_nutricionista)
);
CREATE TABLE relacao_paciente_receita (
    id_paciente INTEGER,
    id_receita INTEGER,
    PRIMARY KEY (id_paciente, id_receita),
    FOREIGN KEY (id_paciente) REFERENCES paciente(id_paciente),
    FOREIGN KEY (id_receita) REFERENCES receita(id_receita)
);
CREATE TABLE relacao_nutricionista_receita (
    id_receita INTEGER,
    id_nutricionista INTEGER,
    PRIMARY KEY (id_receita, id_nutricionista),
    FOREIGN KEY (id_receita) REFERENCES receita(id_receita),
    FOREIGN KEY (id_nutricionista) REFERENCES nutricionista(id_nutricionista)
);
CREATE TABLE relacao_paciente_dieta (
    id_dieta INTEGER,
    id_paciente INTEGER,
    PRIMARY KEY (id_dieta, id_paciente),
    FOREIGN KEY (id_dieta) REFERENCES dieta(id_dieta),
    FOREIGN KEY (id_paciente) REFERENCES paciente(id_paciente)
);
CREATE TABLE valida_dieta (
    id_medico INTEGER,
    id_dieta INTEGER,
    PRIMARY KEY (id_medico, id_dieta),
    FOREIGN KEY (id_medico) REFERENCES medico(id_medico),
    FOREIGN KEY (id_dieta) REFERENCES dieta(id_dieta)
);
CREATE TABLE valida_receita (
    id_receita INTEGER,
    id_medico INTEGER,
    PRIMARY KEY (id_receita, id_medico),
    FOREIGN KEY (id_receita) REFERENCES receita(id_receita),
    FOREIGN KEY (id_medico) REFERENCES medico(id_medico)
);
CREATE TABLE valida_dados_antropometricos (
    id_medida INTEGER,
    id_medico INTEGER,
    PRIMARY KEY (id_medida, id_medico),
    FOREIGN KEY (id_medida) REFERENCES dados_antropometricos(id_medida),
    FOREIGN KEY (id_medico) REFERENCES medico(id_medico)
);
CREATE TABLE valida_diario (
    id_nutricionista INTEGER,
    id_diario INTEGER,
    PRIMARY KEY (id_nutricionista, id_diario),
    FOREIGN KEY (id_nutricionista) REFERENCES nutricionista(id_nutricionista),
    FOREIGN KEY (id_diario) REFERENCES diario_de_alimentos(id_diario)
);
CREATE TABLE relacao_paciente_consulta (
    id_consulta INTEGER,
    id_paciente INTEGER,
    PRIMARY KEY (id_consulta, id_paciente),
    FOREIGN KEY (id_consulta) REFERENCES consulta(id_consulta),
    FOREIGN KEY (id_paciente) REFERENCES paciente(id_paciente)
);
CREATE TABLE relacao_consulta_nutricionista (
    id_consulta INTEGER,
    id_nutricionista INTEGER,
    PRIMARY KEY (id_consulta, id_nutricionista),
    FOREIGN KEY (id_consulta) REFERENCES consulta(id_consulta),
    FOREIGN KEY (id_nutricionista) REFERENCES nutricionista(id_nutricionista)
);
CREATE TABLE relacao_consulta_medico (
    id_consulta INTEGER,
    id_medico INTEGER,
    PRIMARY KEY (id_consulta, id_medico),
    FOREIGN KEY (id_consulta) REFERENCES consulta(id_consulta),
    FOREIGN KEY (id_medico) REFERENCES medico(id_medico)
);
";

// Executa a consulta para criar a tabela
$result = $db->exec($sql);

// Verifica se a consulta foi executada com sucesso
if ($result) {
    echo "Tabela 'usuarios' criada com sucesso!\n";
} else {
    echo "Erro ao criar a tabela: " . $db->lastErrorMsg() . "\n";
}

// Fecha a conexão com o banco de dados (opcional, mas recomendado)
?>