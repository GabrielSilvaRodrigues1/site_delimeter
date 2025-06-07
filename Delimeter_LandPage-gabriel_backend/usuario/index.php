<?php include 'header.php'; ?>
<main>
<?php
session_start();
if (!isset($_SESSION['user_id'])) {
    header('Location: ../entrar_usuario.php');
    exit();
}
?>
    <div class="container-calc">
        <form action="user_tipo.php" method="POST" id="formulario">
            <div class="container">
                <h1>Entrar como:</h1>
                <div class="form-group">
                    <label for="tipo_usuario">Nome:</label>
                    <select name="tipo_usuario" id="tipo_usuario">
                        <option value="paciente" id="paciente">Paciente</option>
                        <option value="nutricionista" id="paciente">Nutricionista</option>
                        <option value="medico" id="paciente">Médico</option>
                    </select>
                </div>
                <button value="submit">Entrar</button>
            </div>
        </form>
    </div>
</main>
<?php include 'footer.php'; ?>