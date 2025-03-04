# Comece com a imagem base oficial do Python.
FROM python:3.12

# Defina o diretório de trabalho atual como /code.
# É aqui que colocaremos o arquivo requirements.txt e o diretório app.
# Todas as instruções subsequentes em nosso Dockerfile começarão neste diretório.
WORKDIR /code

# Copie o arquivo de requisitos para o diretório /code.
# Copie primeiro apenas o arquivo de requisitos, não o restante do código.
# Como este arquivo não muda frequentemente, o Docker irá detectar isso e usará o cache nesta etapa,
# habilitando o cache para a próxima etapa também.
# Usado para armazenar em cache os requisitos, evitando reinstalações a cada alteração no código-fonte.
COPY ./requirements.txt /code/requirements.txt

# Instale as dependências de pacotes listadas no arquivo de requisitos.
# A opção --no-cache-dir informa ao pip para não salvar os pacotes baixados localmente, pois isso só seria útil
# se o pip fosse executado novamente para instalar os mesmos pacotes, o que não é o caso em containers.
# É equivalente a abrir um terminal e executar este comando
RUN pip install --no-cache-dir --upgrade -r /code/requirements.txt

# Copie o diretório ./app para dentro do diretório /code.
# Como isso inclui todo o código que muda com mais frequência, o cache do Docker não será usado facilmente
# para esta ou as próximas etapas.
# Por isso é importante colocar esta instrução no final do Dockerfile para otimizar os tempos de build da imagem.
# Copie o código-fonte para o diretório de trabalho atual
COPY ./app /code/app

# Defina as portas de rede que este container irá escutar durante a execução
EXPOSE 8000

# Só pode haver um comando CMD por Dockerfile
# Ele informa ao container como executar a aplicação
# Diferentemente de um comando regular, não inicia uma sessão shell (formato exec)
# Configure o comando para usar fastapi run, que utiliza Uvicorn internamente.

# CMD recebe uma lista de strings, onde cada string representa o que você digitaria na linha de comando
# separado por espaços.
# Este comando será executado a partir do diretório de trabalho atual (/code definido anteriormente com WORKDIR)
CMD ["fastapi", "run", "app/main.py", "--port", "8000"]