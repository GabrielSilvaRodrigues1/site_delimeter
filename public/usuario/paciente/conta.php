<?php
session_start();
if (!isset($_SESSION['user_id'])) {
    header('Location: ../entrar_usuario.php');
    exit();
}
include __DIR__ . 'header.php'; ?>
<main id="conteudo" tabindex="-1" aria-labelledby="titulo-principal">
    <h1 id="titulo-principal">Minha Conta</h1>
    <!-- Conteúdo da conta aqui -->
</main>
<?php include __DIR__ . 'footer.php'; ?>