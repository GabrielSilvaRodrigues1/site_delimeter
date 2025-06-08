<!DOCTYPE html>
<html lang="pt-br">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Deliméter - Priorize sua Alimentação</title>
    <link rel="stylesheet" href="styles/styles.css">
</head>

<body>
    <header>
        <div class="logo">
            <a href="index.php"><img src="../../assets/images/logo.png" alt="Logo Delímiter"></a>
        </div>
        <div class="menu-hamburguer">
            <input type="checkbox" id="menu-toggle">
            <label for="menu-toggle" class="menu-icon">
                <div class="linha"></div>
                <div class="linha"></div>
                <div class="linha"></div>
            </label>
            <div class="overlay">
                <nav>
                    <ul>
                        <li><a href="../../about.php" class="link">Sobre Nós</a></li>
                        <li><a href="../../calculo_landpage.php" class="link">Cálculo nutricional</a></li>
                        <li><a href="conta.php" class="link">Conta</a></li>
                        <li><a href="../sair_usuario.php" class="link">Sair</a></li>
                        <nav aria-label="Acessibilidade" class="acessibilidade">
                            <button onclick="toggleContraste()" id="contraste-btn" aria-pressed="false" aria-label="Ativar ou desativar alto contraste">Alto Contraste</button>
                            <button onclick="aumentarFonte()" id="aumentar-fonte-btn" aria-label="Aumentar tamanho da fonte" accesskey="2" tabindex="2">A+</button>
                            <button onclick="diminuirFonte()" id="diminuir-fonte-btn" aria-label="Diminuir tamanho da fonte" accesskey="3" tabindex="3">A-</button>
                        </nav>
                    </ul>
                </nav>
            </div>
        </div>
    </header>