<?php
    $banco = new PDO('sqlite:database/database.db');

    $nome = $_POST['nome'];
    $email = $_POST['email'];
    $senha =password_hash($_POST['senha'],PASSWORD_DEFAULT);

    $sql = "INSERT INTO usuario (nome_usuario, email_usuario, senha_usuario) VALUES (:nome, :email, :senha)";
    $stmt=$banco->prepare($sql);
    $stmt->execute([
        ':nome'=>$nome,
        ':email'=>$email,
        ':senha'=>$senha
    ]);
        header("Location: entrar_usuario.php");
        exit();
?>