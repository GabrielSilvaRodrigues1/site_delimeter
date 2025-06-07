<?php
session_start();

try {
    $banco = new PDO('mysql:host=db;dbname=delimeter;charset=utf8', 'root', 'root');
    $banco->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    $email = $_POST['email'];
    $senha = $_POST['senha'];

    $sql = "SELECT * FROM usuario WHERE email_usuario = :email";
    $stmt = $banco->prepare($sql);
    $stmt->execute([':email' => $email]);
    $usuario = $stmt->fetch(PDO::FETCH_ASSOC);

    if ($usuario && password_verify($senha, $usuario['senha_usuario'])) {
        $_SESSION['user_id'] = $usuario['id_usuario'];
        $_SESSION['user_email'] = $usuario['email_usuario'];
        header('Location: usuario/index.php');
        exit();
    } else {
        echo "Senha ou usuário incorretos!";
    }
} catch (PDOException $e) {
    echo "Erro ao conectar ao banco de dados: " . $e->getMessage();
}
?>