<?php include 'header.php'; ?>
  <main>
    <section class="container-main">
      <div class="container-main-image">
        <img src="images/almoço.jpg" alt="Alimentação saudável">
        <h1>PRIORIZAMOS A SUA ALIMENTAÇÃO</h1>
      </div>
    </section>
    <div class="container-calc">
      <div class="container">
        <h1>Cálculo de Gasto Energético</h1>
        <form id="formulario">
          <div class="form-group">
            <label for="nome">Nome</label>
            <input type="text" name="nome" required id="nome">
          </div>
          <div class="form-group">
            <label for="idade">Idade</label>
            <input type="number" name="idade" required id="idade">
          </div>
          <div class="form-group">
            <label for="sexo">Sexo</label>
            <select name="sexo" required id="sexo">
              <option value="">Selecione</option>
              <option value="masculino">MASCULINO</option>
              <option value="feminino">FEMININO</option>
            </select>
          </div>
          <div class="form-group">
            <label for="peso">Peso</label>
            <input type="number" name="peso" step="0.01" required id="peso">
          </div>
          <div class="form-group">
            <label for="altura">Altura (em centímetros)</label>
            <input type="number" name="altura" step="0.01" required id="altura">
          </div>
          <div class="form-group">
            <label for="atividade">Nível de atividade física</label>
            <select name="atividade" required id="atividade">
              <option value="">Selecione</option>
              <option value="sedentário">Sedentário</option>
              <option value="moderadamente ativo">Moderadamente ativo</option>
              <option value="ativo">Ativo</option>
            </select>
          </div>
          <button type="button" onclick="if (validarFormulario()) enviarDados();">Enviar</button>
        </form>
      </div>
      <div class="container" id="resultado"></div>
    </div>
  </main>
<?php include 'footer.php'; ?>