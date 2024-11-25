from flask import Flask, request, jsonify
from unidecode import unidecode
import google.generativeai as genai
import pandas as pd
from concurrent.futures import ThreadPoolExecutor, as_completed
import json

# Configuração da chave da API
genai.configure(api_key="")
app = Flask(__name__)

# Configurar Flask para usar UTF-8 na resposta JSON
app.config['JSON_AS_ASCII'] = False

# Função para ler um arquivo Excel e formatar o conteúdo como texto
def ler_dados_do_arquivo(caminho_arquivo):
    try:
        df = pd.read_excel(caminho_arquivo)
        # Limitar o número de linhas para evitar excesso de dados
        return f"\nDados do arquivo {caminho_arquivo}:\n{df.head(800).to_string(index=False)}\n"
    except Exception as e:
        return f"Erro ao ler o arquivo {caminho_arquivo}: {e}"

# Função para gerar resposta da IA com os dados dos arquivos incluídos no prompt
def gerar_resposta(caminhos_arquivos, pergunta):
    dados_formatados = ""
    
    # Ler arquivos em paralelo
    with ThreadPoolExecutor() as executor:
        futures = {executor.submit(ler_dados_do_arquivo, caminho): caminho for caminho in caminhos_arquivos}
        
        for future in as_completed(futures):
            resultado = future.result()
            if "Erro" not in resultado:
                dados_formatados += resultado
            else:
                print(resultado)

    if dados_formatados:
        prompt = f"""Você é o KAI (Kodiak AI Intelligence), o assistente virtual oficial da Kodiak, especializado em análise de dados empresariais e suporte ao cliente.

        SUAS CARACTERÍSTICAS:
        - Profissional e cordial
        - Respostas objetivas e diretas
        - Foco em métricas e resultados
        - Uso de linguagem corporativa apropriada
        - Capacidade de análise de dados comerciais

        DIRETRIZES DE RESPOSTA:
        1. Sempre cumprimente o usuário de forma profissional
        2. Mantenha as respostas concisas e focadas (máximo 3 parágrafos)
        3. Quando relevante, inclua números e métricas específicas
        4. Para valores monetários, use formato R$ X.XXX,XX
        5. Ao mencionar clientes, use sempre o nome fantasia
        6. Ao fornecer respostas, seja objetivo e não gere respostas muito longas
        7. Ao fornecer respostas, não mencione nada nas respostas sobre tabelas do banco, por exemplo: fatec_vendas, fatec_clientes

        CAPACIDADES:
        - Análise de vendas e faturamento
        - Informações sobre clientes e produtos
        - Status de contas a receber
        - Análise de tendências e padrões
        - Geração de insights comerciais

        QUANDO NÃO SOUBER RESPONDER:
        1. Mantenha a postura profissional
        2. Ofereça alternativas relacionadas
        3. Sugira 1-2 perguntas relevantes baseadas nos dados disponíveis
        4. Exemplo: "Embora não possa responder diretamente sua pergunta, posso ajudar com informações sobre [alternativas]..."

        DADOS DISPONÍVEIS PARA ANÁLISE:
        {dados_formatados}

        PERGUNTA DO USUÁRIO:
        {pergunta}

        Lembre-se: Você é a interface profissional da Kodiak. Mantenha sempre o foco em agregar valor ao negócio."""
        
        try:
            model = genai.GenerativeModel(model_name="gemini-1.5-flash")
            response = model.generate_content(prompt)
            return response.text
        except Exception as e:
            return f"Erro ao gerar resposta: {e}"
    else:
        return "Não foi possível ler os dados dos arquivos Excel."

# Rota principal para receber perguntas
@app.route('/perguntar', methods=['POST'])
def perguntar():
    data = request.get_json()
    if not data or 'pergunta' not in data:
        return jsonify({"erro": "Formato inválido. Certifique-se de enviar um JSON com a chave 'pergunta'."}), 400
    
    pergunta = data['pergunta']
    
    caminhos_arquivos = [
        "C:\\Users\\Matheus\\Documents\\tabelas_csv\\fatec_clientes.xlsx",
        "C:\\Users\\Matheus\\Documents\\tabelas_csv\\fatec_contas_receber.xlsx",
        "C:\\Users\\Matheus\\Documents\\tabelas_csv\\fatec_produtos.xlsx",
        "C:\\Users\\Matheus\\Documents\\tabelas_csv\\fatec_vendas.xlsx"
    ]
    
    resposta = gerar_resposta(caminhos_arquivos, pergunta)
    
    # Forçar codificação UTF-8 na resposta
    return app.response_class(
        response=json.dumps({"resposta": resposta}, ensure_ascii=False),
        status=200,
        mimetype='application/json'
    )

if __name__ == '__main__':
    app.run(debug=True)