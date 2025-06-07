<?php

namespace src\Models\Repository;

use src\Models\Entity\Usuario;
use PDO;

class UsuarioRepository
{
    private $conn;

    public function __construct(PDO $conn)
    {
        $this->conn = $conn;
    }

    public function add(Usuario $usuario): bool
    {
        $sql = "INSERT INTO usuario (nome_usuario, email_usuario, senha_usuario) VALUES (:nome, :email, :senha)";
        $stmt = $this->conn->prepare($sql);
        return $stmt->execute([
            ':nome' => $usuario->getNomeUsuario(),
            ':email' => $usuario->getEmailUsuario(),
            ':senha' => $usuario->getSenhaUsuario()
        ]);
    }

    public function findById(int $id): ?Usuario
    {
        $sql = "SELECT * FROM usuario WHERE id_usuario = :id";
        $stmt = $this->conn->prepare($sql);
        $stmt->execute([':id' => $id]);
        $row = $stmt->fetch(PDO::FETCH_ASSOC);
        if ($row) {
            $usuario = new Usuario($row['nome_usuario'], $row['email_usuario'], $row['senha_usuario']);
            $usuario->setIdUsuario($row['id_usuario']);
            return $usuario;
        }
        return null;
    }

    public function findAll(): array
    {
        $sql = "SELECT * FROM usuario";
        $stmt = $this->conn->query($sql);
        $usuarios = [];
        while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
            $usuario = new Usuario($row['nome_usuario'], $row['email_usuario'], $row['senha_usuario']);
            $usuario->setIdUsuario($row['id_usuario']);
            $usuarios[] = $usuario;
        }
        return $usuarios;
    }

    public function removeById(int $id): bool
    {
        $sql = "DELETE FROM usuario WHERE id_usuario = :id";
        $stmt = $this->conn->prepare($sql);
        return $stmt->execute([':id' => $id]);
    }
}
?>