<?php

namespace src\Models\Repository;

use src\Models\Entity\Nutricionista;
use PDO;

class NutricionistaRepository
{
    private $conn;

    public function __construct(PDO $conn)
    {
        $this->conn = $conn;
    }

    public function add(Nutricionista $nutricionista): bool
    {
        $sql = "INSERT INTO nutricionista (id_usuario, crm_nutricionista) VALUES (:id_usuario, :crm)";
        $stmt = $this->conn->prepare($sql);
        return $stmt->execute([
            ':id_usuario' => $nutricionista->getIdUsuario(),
            ':crm' => $nutricionista->getCrmNutricionista()
        ]);
    }

    public function findById(int $id): ?Nutricionista
    {
        $sql = "SELECT * FROM nutricionista WHERE id_nutricionista = :id";
        $stmt = $this->conn->prepare($sql);
        $stmt->execute([':id' => $id]);
        $row = $stmt->fetch(PDO::FETCH_ASSOC);
        if ($row) {
            $nutricionista = new Nutricionista($row['id_usuario'], $row['crm_nutricionista']);
            $nutricionista->setIdNutricionista($row['id_nutricionista']);
            return $nutricionista;
        }
        return null;
    }

    public function findAll(): array
    {
        $sql = "SELECT * FROM nutricionista";
        $stmt = $this->conn->query($sql);
        $nutricionistas = [];
        while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
            $nutricionista = new Nutricionista($row['id_usuario'], $row['crm_nutricionista']);
            $nutricionista->setIdNutricionista($row['id_nutricionista']);
            $nutricionistas[] = $nutricionista;
        }
        return $nutricionistas;
    }

    public function update(Nutricionista $nutricionista): bool
    {
        $sql = "UPDATE nutricionista SET id_usuario = :id_usuario, crm_nutricionista = :crm WHERE id_nutricionista = :id";
        $stmt = $this->conn->prepare($sql);
        return $stmt->execute([
            ':id_usuario' => $nutricionista->getIdUsuario(),
            ':crm' => $nutricionista->getCrmNutricionista(),
            ':id' => $nutricionista->getIdNutricionista()
        ]);
    }

    public function removeById(int $id): bool
    {
        $sql = "DELETE FROM nutricionista WHERE id_nutricionista = :id";
        $stmt = $this->conn->prepare($sql);
        return $stmt->execute([':id' => $id]);
    }
}
?>