<?php
namespace src\Config;
use PDO;
use PDOException;

class Connection {
    private $host = "db";
    private $db_name = "delimeter";
    private $username = "root";
    private $password = "root";
    private $conn;

    public function getConnection() {
        try {
            $this->conn = new PDO(
                "mysql:host={$this->host};dbname={$this->db_name};charset=utf8",
                $this->username,
                $this->password
            );
            $this->conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
        } catch (PDOException $error) {
            echo "Erro ao conectar ao banco de dados: " . $error->getMessage();
        }
        return $this->conn;
    }
}
?>