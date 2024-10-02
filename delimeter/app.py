import csv
from flask import Flask, render_template, send_from_directory, request, redirect, url_for
import os
import pandas as pd
app = Flask(__name__)
lista_opcoes = ["Gasto Energético Total (GET)", "Necessidades Proteicas", "Necessidades de Carboidratos e Lipídios", "Índice de Massa Corporal (IMC)", "Taxa Metabólica Basal (TMB)", "Gasto Energético com Atividade Física (GEAF)", "Gasto Energético com Atividade Física (GEAF)"]


def carregar_usuarios():
    if os.path.exists('data/usuarios.csv'):
        df = pd.read_csv('data/usuarios.csv')
        return df.to_dict('records')
    return []

def salvar_usuario(nome, email, telefone, senha):
    try:
        df = pd.read_csv('data/usuarios.csv', index_col=False)
        new_row = pd.DataFrame({'nome': [nome], 'email': [email], 'telefone': [telefone], 'senha': [senha]})
        df = pd.concat([df, new_row], ignore_index=True)
        df.to_csv('data/usuarios.csv', index=False)
    except Exception as e:
        print(f"Erro ao salvar usuário: {e}")
        return False

def buscar_usuario_por_email(email):
    df = pd.read_csv('data/usuarios.csv')
    usuario = df[df['email'] == email].to_dict('records')
    return usuario[0] if usuario else None

@app.route('/', methods=['GET', 'POST'])
def index():
    if request.method == 'POST':
        if usuario and usuario['senha'] == senha:
            return redirect(url_for('area_usuario'))
        else:
            return render_template('usuarios.html', erro='Email ou senha inválidos')
    else:
        return render_template('index.html', lista = lista_opcoes)
@app.route('/entrar', methods=['GET', 'POST'])
def entrar():
    if request.method == 'POST':
        email = request.form['email']
        senha = request.form['senha']
        usuario = buscar_usuario_por_email(email)
        if usuario and usuario['senha'] == senha:
            return redirect(url_for('area_usuario'))
        else:
            return render_template('entrar.html', erro='Email ou senha inválidos')
    else:
        return render_template('entrar.html')
@app.route('/cadastro_usuario', methods=['GET', 'POST'])
def cadastro_usuario():
    if request.method == 'POST':
        nome = request.form['nome']
        email = request.form['email']
        telefone = request.form['telefone']
        senha = request.form['senha']
        salvar_usuario(nome, email, telefone, senha)
        return redirect(url_for('entrar'))
    else:
        return render_template('cadastro_usuario.html')
@app.route('/cadastro_profissional', methods=['GET', 'POST'])
def cadastro_profissional():
    if request.method == 'POST':
        nome = request.form['nome']
        email = request.form['email']
        telefone = request.form['telefone']
        senha = request.form['senha']
        salvar_usuario(nome, email, telefone, senha)
        return redirect(url_for('entrar'))
    else:
        return render_template('cadastro_profissional.html')        
# ... (outras rotas, adaptando para ler e escrever no arquivo CSV)
@app.route('/area_usuario')
def area_usuario():
    return render_template('area_usuario.html')
@app.route('/base')
def base():
    return render_template('base.html', lista = lista_opcoes)
@app.route('/usuarios')
def usuarios():
    usuarios = carregar_usuarios()
    return render_template('usuarios.html', usuarios=usuarios)
if __name__ == '__main__':
    app.run(debug=True)