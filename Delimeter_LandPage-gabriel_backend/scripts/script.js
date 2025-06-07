function validarFormulario() {
    const formulario = document.getElementById('formulario');
    const camposObrigatorios = formulario.querySelectorAll('[required]');
    let formularioValido = true;

    camposObrigatorios.forEach(campo => {
        if (!campo.value) {
            formularioValido = false;
            campo.classList.add('erro');
            if (!campo.nextElementSibling || !campo.nextElementSibling.classList.contains('mensagem-erro')) {
                const mensagemErro = document.createElement('span');
                mensagemErro.classList.add('mensagem-erro');
                mensagemErro.textContent = 'Este campo é obrigatório.';
                campo.parentNode.insertBefore(mensagemErro, campo.nextSibling);
            }
        } else {
            campo.classList.remove('erro');
            if (campo.nextElementSibling && campo.nextElementSibling.classList.contains('mensagem-erro')) {
                campo.nextElementSibling.remove();
            }
        }
    });

    return formularioValido;
}

function enviarDados() {
    if (!validarFormulario()) {
        return; // Impede o envio se o formulário não for válido
    }

    const nome = document.getElementById('nome').value;
    const idade = parseInt(document.getElementById('idade').value);
    const sexo = document.getElementById('sexo').value;
    const peso = parseFloat(document.getElementById('peso').value);
    const alturaN = parseFloat(document.getElementById('altura').value);
    const altura = alturaN / 100;
    const atividade = document.getElementById('atividade').value;

    const imc = peso / (altura * altura);
    const pesoIdeal = ((altura ** 2) * 21.7).toFixed(1);
    let classificado = '';
    let corIMC = '';
    let fatorAtividade = { 'sedentário': 1.55, 'moderadamente ativo': 1.85, 'ativo': 2.20 }[atividade] || 1.55;

    if (imc < 18.5) { classificado = "Baixo peso"; corIMC = "blue"; }
    else if (imc <= 24.99) { classificado = "Eutrofia"; corIMC = "green"; }
    else if (imc <= 29.99) { classificado = "Sobrepeso"; corIMC = "orange"; }
    else { classificado = "Obesidade"; corIMC = "red"; }

    let geb, gebIdeal;
    if (sexo === 'masculino') {
        if (idade <= 3) { geb = (59.512 * peso) - 30.4; gebIdeal = (59.512 * pesoIdeal) - 30.4; }
        else if (idade <= 10) { geb = (22.706 * peso) + 504.3; gebIdeal = (22.706 * pesoIdeal) + 504.3; }
        else if (idade <= 18) { geb = (17.686 * peso) + 658.2; gebIdeal = (17.686 * pesoIdeal) + 658.2; }
        else if (idade <= 30) { geb = (15.057 * peso) + 692.2; gebIdeal = (15.057 * pesoIdeal) + 692.2; }
        else if (idade <= 60) { geb = (11.472 * peso) + 873.1; gebIdeal = (11.472 * pesoIdeal) + 873.1; }
        else { geb = (11.711 * peso) + 587.7; gebIdeal = (11.711 * pesoIdeal) + 587.7; }
    } else {
        if (idade <= 3) { geb = (58.31 * peso) - 31.1; gebIdeal = (58.31 * pesoIdeal) - 31.1; }
        else if (idade <= 10) { geb = (20.315 * peso) + 485.9; gebIdeal = (20.315 * pesoIdeal) + 485.9; }
        else if (idade <= 18) { geb = (13.384 * peso) + 692.6; gebIdeal = (13.384 * pesoIdeal) + 692.6; }
        else if (idade <= 30) { geb = (14.818 * peso) + 486.6; gebIdeal = (14.818 * pesoIdeal) + 486.6; }
        else if (idade <= 60) { geb = (8.126 * peso) + 845.6; gebIdeal = (8.126 * pesoIdeal) + 845.6; }
        else { geb = (9.082 * peso) + 658.5; gebIdeal = (9.082 * pesoIdeal) + 658.5; }
    }

    const get = geb * fatorAtividade;
    const getIdeal = gebIdeal * fatorAtividade;

    const proteinaMin = getIdeal * 0.10;
    const proteinaMax = getIdeal * 0.15;

    const gramagemProteinaMin = proteinaMin / 4;
    const gramagemProteinaMax = proteinaMax / 4;

    const carboidratosMin = getIdeal * 0.15;
    const carboidratosMax = getIdeal * 0.30;

    const gramagemCarboidratoMin = carboidratosMin / 4;
    const gramagemCarboidratoMax = carboidratosMax / 4;

    const lipidiosMin = getIdeal * 0.55;
    const lipidiosMax = getIdeal * 0.75;

    const gramagemLipidioMin = lipidiosMin / 9;
    const gramagemLipidioMax = lipidiosMax / 9;

    const refeicoes = {
        '🍞 Café da manhã': getIdeal * 0.25,
        '🍎 Lanche da manhã': getIdeal * 0.05,
        '🍛 Almoço': getIdeal * 0.35,
        '☕ Lanche da tarde': getIdeal * 0.10,
        '🍽️ Jantar': getIdeal * 0.15,
        '🥛 Lanche da noite': getIdeal * 0.05,
    };

    const macroNutrientes = {
        '🍚 Carboidratos': {
            min: carboidratosMin.toFixed(1),
            max: carboidratosMax.toFixed(1),
            gramasMin: gramagemCarboidratoMin.toFixed(1),
            gramasMax: gramagemCarboidratoMax.toFixed(1),
            cor: 'green',
        },
        '🍗 Proteínas': {
            min: proteinaMin.toFixed(1),
            max: proteinaMax.toFixed(1),
            gramasMin: gramagemProteinaMin.toFixed(1),
            gramasMax: gramagemProteinaMax.toFixed(1),
            cor: 'red',
        },
        '🥑 Lipídios': {
            min: lipidiosMin.toFixed(1),
            max: lipidiosMax.toFixed(1),
            gramasMin: gramagemLipidioMin.toFixed(1),
            gramasMax: gramagemLipidioMax.toFixed(1),
            cor: 'orange',
        },
    };

    let resultadoDiv = document.getElementById('resultado');
    resultadoDiv.innerHTML = `
        <p><strong>Nome:</strong> ${nome}</p>
        <p><strong>Idade:</strong> ${idade}</p>
        <p><strong>Sexo:</strong> ${sexo}</p>
        <p><strong>Peso:</strong> ${peso} kg</p>
        <p><strong>Altura:</strong> ${altura} m</p>
        <p><strong>Atividade Física:</strong> ${atividade}</p>
        <p><strong>IMC:</strong> <span style='background-color: ${corIMC};'>${imc.toFixed(1)}</span></p>
        <p><strong>Classificação corporal:</strong> ${classificado}</p>
        <p><strong>Gasto Energético Basal:</strong> ${geb.toFixed(1)} Kcal</p>
        <p><strong>Gasto Energético Total:</strong> ${get.toFixed(1)} Kcal</p>
        <p><strong>Gasto Energético Total Ideal:</strong> ${getIdeal.toFixed(1)} Kcal</p>
        <hr>
        <h3>Distribuição energética</h3>
        ${Object.entries(refeicoes).map(([refeicao, valor]) => `<p><strong>${refeicao}:</strong> ${valor.toFixed(1)} Kcal</p>`).join('')}
        <hr>
        <h3>Macro nutrientes</h3>
        ${Object.entries(macroNutrientes).map(([nutriente, dados]) => `
            <p><strong>${nutriente}:</strong> Mínimo <span style='background-color: ${dados.cor};'>${dados.min}</span> Kcal (${dados.gramasMin} gramas) e máximo <span style='background-color: ${dados.cor};'>${dados.max}</span> Kcal (${dados.gramasMax} gramas)</p>
        `).join('')}
        
    `;
    resultadoDiv.style.display = 'block'; // Mostra a div
}


