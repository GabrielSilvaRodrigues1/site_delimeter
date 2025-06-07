<?php include 'header.php'; ?>
<?php
session_start();
if (!isset($_SESSION['user_id'])) {
    header('Location: ../../entrar_usuario.php');
    exit();
}
?>
    <main>
        <section class="container-main">
            <div class="container-main-image">
                <img src="images/almoço.jpg" alt="Pessoas em uma mesa distribuindo refeições">
            </div>
        </section>
        <section class="about">
            <h1>Bem-Vindo ao Deliméter para Médicos</h1>
            <div class="caixas">
                <div class="caixa">
                    <p>O <span>Deliméter</span> é um projeto integrador voltado à nutrição de pessoas carentes, unindo tecnologia e alimentação saudável para combater a insegurança alimentar. Ele visa oferecer soluções inovadoras para facilitar o acesso a alimentos nutritivos, promover educação alimentar e otimizar a distribuição de recursos para comunidades em situação de vulnerabilidade. O projeto utiliza ferramentas tecnológicas para coleta e análise de dados, permitindo um planejamento eficiente e um impacto positivo na qualidade de vida dos beneficiados.</p>
                    <p>O nome <span>Deliméter</span> é inspirado na deusa <span>Deméter</span>, conhecida como a deusa da agricultura na mitologia grega. A parte "Deli" do nome faz referência a <span>delimitação</span>, que é o principal objetivo deste site: delimitar e acompanhar a sua alimentação.</p>
                    <a href="conta.php"><button type="button">Finalize sua Inscrição</button></a>
                </div>
                <img src="../../images/delimeter.png" alt="Deusa delimeter" style="height: 50%;">
            </div>
        </section>
    </main>
<?php include 'footer.php'; ?>