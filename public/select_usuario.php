<?php
session_start();

require_once __DIR__ . '/src/Config/connection.php';

use src\Config\Connection;

try {
    $conn = (new Connection())->getConnection();

    if (!$conn) {
        throw new Exception("Falha na conexão com o banco de dados.");
    }

    $email = $_POST['email'] ?? '';
    $senha = $_POST['senha'] ?? '';

    $sql = "SELECT * FROM usuario WHERE email_usuario = :email";
    $stmt = $conn->prepare($sql);
    $stmt->execute([':email' => $email]);
    $usuario = $stmt->fetch(PDO::FETCH_ASSOC);

    if ($usuario && password_verify($senha, $usuario['senha_usuario'])) {
        $_SESSION['user_id'] = $usuario['id_usuario'];
        $_SESSION['user_name'] = $usuario['nome_usuario'];
        $_SESSION['user_email'] = $usuario['email_usuario'];
        header('Location: usuario/index.php');
        exit();
    } else {
        echo "Senha ou usuário incorretos!";
    }
} catch (Exception $e) {
    echo "Erro ao conectar ao banco de dados: " . $e->getMessage();
}
?>