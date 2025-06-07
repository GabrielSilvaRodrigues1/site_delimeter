<?php

namespace src\Models\Services;
// Importa a classe de conexão e a entidade Aluno
use src\Config\connection;
use src\Models\Entity\Aluno;
use PDO;

// Repositório para operações CRUD com a entidade Aluno
class AlunoRepository{
    public $conn;

    // Construtor: inicializa a conexão com o banco de dados
    public function __construct(){
        // Cria uma nova instância da conexão com o banco de dados
        $database = new conection(); // Atenção: o correto seria 'connection'
        $this->conn = $database->getConnection(); // Obtém o objeto de conexão PDO
    }

    // Salva um novo aluno no banco de dados
    public function save(Aluno $aluno){
        // Monta a query SQL para inserir um novo aluno
        $query = "INSERT INTO aluno (nome, genero) VALUES (:nome, :genero)";
        $nome = $aluno->getNome(); // Obtém o nome do aluno
        $genero = $aluno->getGenero(); // Obtém o gênero do aluno
        $stmt = $this->conn->prepare($query); // Prepara a query
        $stmt->bindParam(':nome', $nome); // Associa o parâmetro :nome
        $stmt->bindParam(':genero', $genero); // Associa o parâmetro :genero
        $stmt->execute(); // Executa a query
    }

    // Retorna todos os alunos cadastrados
    public function findAll(){
        // Monta a query SQL para buscar todos os alunos
        $query = "SELECT * FROM aluno";
        $stmt = $this->conn->prepare($query); // Prepara a query
        $stmt->execute(); // Executa a query
        return $stmt->fetchAll(PDO::FETCH_ASSOC); // Retorna todos os resultados como array associativo
    }

    // Busca um aluno pelo ID
    public function findById($id){
        // Monta a query SQL para buscar um aluno pelo ID
        $query = "SELECT * FROM aluno WHERE id = :id";
        $stmt = $this->conn->prepare($query); // Prepara a query
        $stmt->bindParam(':id', $id); // Associa o parâmetro :id
        $stmt->execute(); // Executa a query
        return $stmt->fetch(PDO::FETCH_ASSOC); // Retorna o resultado como array associativo
    }

    // Atualiza os dados de um aluno existente
    public function update(Aluno $aluno){
        // Monta a query SQL para atualizar um aluno
        $query = "UPDATE aluno SET nome = :nome, genero = :genero WHERE id = :id";
        $stmt = $this->conn->prepare($query); // Prepara a query
        $nome = $aluno->getNome(); // Obtém o nome atualizado
        $genero = $aluno->getGenero(); // Obtém o gênero atualizado
        $id = $aluno->getId(); // Obtém o ID do aluno
        $stmt->bindParam(':nome', $nome); // Associa o parâmetro :nome
        $stmt->bindParam(':genero', $genero); // Associa o parâmetro :genero
        $stmt->bindParam(':id', $id); // Associa o parâmetro :id
        $stmt->execute(); // Executa a query
    }

    // Remove um aluno pelo ID
    public function delete($id){
        // Monta a query SQL para deletar um aluno pelo ID
        $query = "DELETE FROM aluno WHERE id = :id";
        $stmt = $this->conn->prepare($query); // Prepara a query
        $stmt->bindParam(':id', $id); // Associa o parâmetro :id
        $stmt->execute(); // Executa a query
    }
}
?>