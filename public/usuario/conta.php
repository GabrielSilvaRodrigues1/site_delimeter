<?php
session_start();
if (!isset($_SESSION['user_id'])) {
    header('Location: ../entrar_usuario.php');
    exit();
}
include __DIR__ . '/header.php'; ?>
<main id="conteudo" tabindex="-1" aria-labelledby="titulo-principal" class="container">
    <div class="account-card">
        <h1 id="titulo-principal" class="account-title">Minha Conta</h1>
        <section class="account-section">
            <h2 class="section-title">Informações da Conta</h2>
            <ul class="account-info">
                <li><strong>Nome:</strong> <?php echo htmlspecialchars($_SESSION['user_name'] ?? 'Não informado'); ?></li>
                <li><strong>Email:</strong> <?php echo htmlspecialchars($_SESSION['user_email'] ?? 'Não informado'); ?></li>
            </ul>
            <div class="account-actions">
                <a href="update.php" class="btn btn-primary">Editar Informações</a>
                <form action="logout.php" method="post" class="inline-form">
                    <button type="submit" class="btn btn-secondary">Sair da Conta</button>
                </form>
                <form action="../delete.php" method="post" class="inline-form" onsubmit="return confirm('Tem certeza que deseja excluir sua conta? Esta ação não pode ser desfeita.');">
                    <button type="submit" class="btn btn-danger">Excluir Conta</button>
                </form>
            </div>
        </section>
    </div>
</main>
<?php include __DIR__ . '/footer.php'; ?>