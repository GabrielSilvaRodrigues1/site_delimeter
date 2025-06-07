<?php include 'header.php'; ?>
<main>
    <div class="container-calc">
        <form action="select_usuario.php" method="POST" id="formulario">
            <div class="container">
                <h1>Entrar</h1>
                <div class="form-group">
                    <label for="email">Email:</label>
                    <input type="email" name="email" required id="email">
                </div>
                <div class="form-group">
                    <label for="senha">Senha:</label>
                    <input type="password" name="senha" required id="senha">
                </div>
                <button value="submit" onclick="if (validarFormulario()) enviarDados();">Cadastrar</button>
            </div>
        </form>
    </div>
</main>
<?php include 'footer.php'; ?>