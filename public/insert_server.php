<?php
require_once __DIR__ . '/src/Config/connection.php';

use src\Config\Connection;

try {
    $conn = (new Connection())->getConnection();

    if (!$conn) {
        throw new Exception("Falha na conexão com o banco de dados.");
    }

    if (isset($_POST['nome'], $_POST['email'], $_POST['senha'])) {
        $nome = trim($_POST['nome']);
        $email = trim($_POST['email']);
        $senha = password_hash($_POST['senha'], PASSWORD_DEFAULT);

        $sql = "INSERT INTO usuario (nome_usuario, email_usuario, senha_usuario) VALUES (:nome, :email, :senha)";
        $stmt = $conn->prepare($sql);
        $stmt->execute([
            ':nome' => $nome,
            ':email' => $email,
            ':senha' => $senha
        ]);

        header("Location: entrar_usuario.php");
        exit();
    } else {
        echo "Preencha todos os campos.";
    }
} catch (Exception $e) {
    echo "Erro ao cadastrar usuário: " . $e->getMessage();
}
?>