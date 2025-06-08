<?php
session_start();
if (!isset($_SESSION['user_id'])) {
    header('Location: ../entrar_usuario.php');
    exit();
}
include __DIR__ . '/header.php'; ?>

<!-- Bloco de acessibilidade -->
<nav aria-label="Acessibilidade" class="acessibilidade">
    <a href="#conteudo" accesskey="1">Ir para o conteúdo [1]</a>
    <button onclick="toggleContraste()" id="contraste-btn">Alto Contraste</button>
</nav>

<main id="conteudo" tabindex="-1">
    <h1>Minha Conta</h1>
    <!-- Conteúdo da conta aqui -->
</main>

<script>
function toggleContraste() {
    document.body.classList.toggle('alto-contraste');
}
</script>
<style>
/* Exemplo de alto contraste */
.alto-contraste, .alto-contraste * {
    background-color: #000 !important;
    color: #FFD700 !important;
    border-color: #FFD700 !important;
}
.acessibilidade {
    background: #eee;
    padding: 8px;
    display: flex;
    gap: 10px;
}
#acessibilidade a, #contraste-btn {
    font-size: 1em;
}
</style>

<?php include __DIR__ . '/footer.php'; ?>