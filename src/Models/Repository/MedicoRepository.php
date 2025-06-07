<?php

namespace src\Models\Repository;

use src\Models\Entity\Medico;
use PDO;

class MedicoRepository
{
    private $conn;

    public function __construct(PDO $conn)
    {
        $this->conn = $conn;
    }

    public function add(Medico $medico): bool
    {
        $sql = "INSERT INTO medico (id_usuario, crm_medico) VALUES (:id_usuario, :crm)";
        $stmt = $this->conn->prepare($sql);
        return $stmt->execute([
            ':id_usuario' => $medico->getIdUsuario(),
            ':crm' => $medico->getCrmMedico()
        ]);
    }

    public function findById(int $id): ?Medico
    {
        $sql = "SELECT * FROM medico WHERE id_medico = :id";
        $stmt = $this->conn->prepare($sql);
        $stmt->execute([':id' => $id]);
        $row = $stmt->fetch(PDO::FETCH_ASSOC);
        if ($row) {
            $medico = new Medico($row['id_usuario'], $row['crm_medico']);
            $medico->setIdMedico($row['id_medico']);
            return $medico;
        }
        return null;
    }

    public function findAll(): array
    {
        $sql = "SELECT * FROM medico";
        $stmt = $this->conn->query($sql);
        $medicos = [];
        while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
            $medico = new Medico($row['id_usuario'], $row['crm_medico']);
            $medico->setIdMedico($row['id_medico']);
            $medicos[] = $medico;
        }
        return $medicos;
    }

    public function update(Medico $medico): bool
    {
        $sql = "UPDATE medico SET id_usuario = :id_usuario, crm_medico = :crm WHERE id_medico = :id";
        $stmt = $this->conn->prepare($sql);
        return $stmt->execute([
            ':id_usuario' => $medico->getIdUsuario(),
            ':crm' => $medico->getCrmMedico(),
            ':id' => $medico->getIdMedico()
        ]);
    }

    public function removeById(int $id): bool
    {
        $sql = "DELETE FROM medico WHERE id_medico = :id";
        $stmt = $this->conn->prepare($sql);
        return $stmt->execute([':id' => $id]);
    }
}
?>