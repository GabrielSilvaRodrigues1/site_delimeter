<?php
session_start();
if (!isset($_SESSION['user_id'])) {
    header('Location: ../entrar_usuario.php');
    exit();
}
include __DIR__ . '/header.php';

require_once __DIR__ . '/../src/Config/connection.php';

use src\Config\Connection;

$conn = new Connection();
$pdo = $conn->getConnection();

$user_id = $_SESSION['user_id'];
$success = false;
$error = '';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $nome = trim($_POST['nome'] ?? '');
    $email = trim($_POST['email'] ?? '');
    $senha = $_POST['senha'] ?? '';

    if ($nome === '' || $email === '') {
        $error = 'Preencha todos os campos obrigatórios.';
    } else {
        if ($senha !== '') {
            $senha_hash = password_hash($senha, PASSWORD_DEFAULT);
            $stmt = $pdo->prepare('UPDATE usuario SET nome_usuario = ?, email_usuario = ?, senha_usuario = ? WHERE id_usuario = ?');
            $params = [$nome, $email, $senha_hash, $user_id];
        } else {
            $stmt = $pdo->prepare('UPDATE usuario SET nome_usuario = ?, email_usuario = ? WHERE id_usuario = ?');
            $params = [$nome, $email, $user_id];
        }
        if ($stmt->execute($params)) {
            $success = true;
        } else {
            $error = 'Erro ao atualizar cadastro.';
        }
    }
    // Após atualizar, busque os dados atualizados para exibir no formulário
    $stmt = $pdo->prepare('SELECT nome_usuario, email_usuario FROM usuario WHERE id_usuario = ?');
    $stmt->execute([$user_id]);
    $user = $stmt->fetch(PDO::FETCH_ASSOC);
    $nome = $user['nome_usuario'] ?? '';
    $email = $user['email_usuario'] ?? '';
} else {
    $stmt = $pdo->prepare('SELECT nome_usuario, email_usuario FROM usuario WHERE id_usuario = ?');
    $stmt->execute([$user_id]);
    $user = $stmt->fetch(PDO::FETCH_ASSOC);
    $nome = $user['nome_usuario'] ?? '';
    $email = $user['email_usuario'] ?? '';
}
?>

<div class="container">
    <h2>Atualizar Cadastro</h2>
    <?php if ($success): ?>
        <div class="alert alert-success">Cadastro atualizado com sucesso!</div>
    <?php elseif ($error): ?>
        <div class="alert alert-danger"><?= htmlspecialchars($error) ?></div>
    <?php endif; ?>
    <form method="post">
        <div class="mb-3">
            <label for="nome" class="form-label">Nome</label>
            <input type="text" class="form-control" id="nome" name="nome" value="<?= htmlspecialchars($nome ?? '') ?>" required>
        </div>
        <div class="mb-3">
            <label for="email" class="form-label">E-mail</label>
            <input type="email" class="form-control" id="email" name="email" value="<?= htmlspecialchars($email ?? '') ?>" required>
        </div>
        <div class="mb-3">
            <label for="senha" class="form-label">Nova Senha (deixe em branco para não alterar)</label>
            <input type="password" class="form-control" id="senha" name="senha" autocomplete="new-password">
        </div>
        <button type="submit" class="btn btn-primary">Atualizar</button>
    </form>
</div>
<?php include __DIR__ . '/footer.php'; ?>