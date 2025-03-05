# Guia de Prática: Docker e Docker Compose com FastAPI

## Objetivo
Este guia tem como objetivo ensinar os estudantes a utilizar Docker e Docker Compose para containerizar uma aplicação FastAPI. Os passos relacionados ao FastAPI serão explicados brevemente apenas para contextualizar.

## Pré-requisito
- Docker e Docker Compose instalados na máquina
- Conhecimentos básicos sobre linha de comando (utilize o sistema operacional de sua preferência)
- Python 3.12 instalado na máquina
- Um editor de texto da sua preferência

Caso o Docker não esteja instalado em sua máquina, acesse [https://www.docker.com/](https://www.docker.com/)

## Estrutura final do Projeto
Ao final da prática, o projeto deve estar com a seguinte estrutura:</br>
.</br>
├── .dockerignore</br>
├── app</br>
│   ├── __init__.py</br>
│   └── main.py</br>
├── docs</br>
│   └── practice-guide.md</br>
├── docker-compose.yml</br>
├── Dockerfile</br>
├── requirements.txt</br>

## Mãos à obra

### 1. Criar a estrutura de diretórios

No terminal, crie a pasta principal e navegue até ela:
```sh
# Para qualquer terminal
mkdir hello-docker
cd hello-docker
```

Em seguida, crie a pasta `app` para armazenar os arquivos de código fonte da aplicação:
```sh
mkdir app
```

### 3. Criar o arquivo de dependências

Crie o arquivo `requirements.txt` e adicione o seguinte conteúdo a ele:
```
fastapi[standard]>=0.113.0,<0.115.10
pydantic>=2.7.0,<3.0.0
```

### 4. Criar o código fonte da aplicação

1. Dentro do diretório `app/`, crie um arquivo `__init__.py` a fim de tornar `app` um pacote Python.
2. Ainda dentro do `app/`, crie um arquivo `main.py` e adicione o seguinte código fonte a ele:

```python
from fastapi import FastAPI

app = FastAPI()

@app.get("/")
def read_root():
    return {"Hello": "World"}
```

### 5. Criar o Dockerfile e executando um container a partir de uma imagem

1. Crie a Dockerfile necessária para executar um *container* a partir da imagem base do Python 3.12 (os comentários explicam cada comando):

```dockerfile
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
```

2. Execute o comando `docker build` de modo a construir uma imagem a partir do *Dockerfile* criado
anteriormente (a opção `-t` criará uma *tag*, isto é, um nome para a imagem construída):
```sh
docker build -t hello-docker-fastapi:1.0 .
```

3. Para ver se a imagem foi criada, execute o seguinte comando em um terminal:
```sh
docker images
```

4. Agora, para executar um *container* a partir da imagem criada, use o comando `docker run`.
Utilizaremos a opção `-p` para mapear uma porta da nossa máquina para uma porta do *container*
(`porta_local:porta_no_container`) e, em seguida, passaremos a *tag* criada anteriormente para
dizer a partir de qual imagem queremos criar o *container*:
```sh
docker run -p 8001:8000 hello-docker-fastapi:1.0
```

5. Caso tudo dê certo, você deve ver o seguinte *log* em seu terminal:
```
   FastAPI   Starting production server 🚀
 
             Searching for package file structure from directories with 
             __init__.py files
             Importing from /code
 
    module   📁 app
             ├── 🐍 __init__.py
             └── 🐍 main.py
 
      code   Importing the FastAPI app object from the module with the following
             code:
 
             from app.main import app
 
       app   Using import string: app.main:app
 
    server   Server started at http://0.0.0.0:8000
    server   Documentation at http://0.0.0.0:8000/docs
 
             Logs:
 
      INFO   Started server process [1]
      INFO   Waiting for application startup.
      INFO   Application startup complete.
      INFO   Uvicorn running on http://0.0.0.0:8000 (Press CTRL+C to quit)

```

6. Para acessar a API, utilize a URL [http://0.0.0.0:8001/docs](http://0.0.0.0:8001/docs)
(*link* para a documentação da API criada com os seus *endpoints*)

7. Pare o *container* antes de prosseguirmos para a próxima etapa (Ctrl + C na janela do terminal
onde o comando `docker run` foi executado ou clicando no botão *Stop* no *container* através do
Docker Desktop).

### 6. Executando múltiplos containers ao mesmo tempo com Docker Compose

1. Agora que já conseguimos executar um *container*, vamos supor que queremos também executar um
*container* para o nosso banco de dados PostgreSQL. Para isso, utilizaremos Docker Compose. Desse
modo, crie um arquivo `docker-compose.yml` na raíz do projeto e insira o seguinte conteúdo nele:
```yml
# Essa seção define os serviços (ou containers) que serão criados e gerenciados pelo Compose
services:
  # Define um serviço chamado hello_docker_db (um container) que será responsável por executar o PostgreSQL
  hello_docker_db:
    # Define que o container será criado a partir da imagem oficial do PostgreSQL (Disponível no Docker Hub)
    image: postgres
    # Especifica um nome personalizado para o container
    container_name: hello_docker_db
    # Aqui, é utilizado um volume nomeado chamado pgdata para mapear o diretório onde o PostgreSQL
    # armazena seus dados (/var/lib/postgresql/data). Isso garante que os dados do banco sejam
    # persistentes mesmo que o container seja reiniciado ou removido.
    volumes:
      - pgdata:/var/lib/postgresql/data
    # Define as variáveis de ambiente que serão utilizadas para configurar o PostgreSQL
    environment:
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres
      POSTGRES_DB: hello_docker
    # Mapeia a porta 5433 do host para a porta 5432 do container, permitindo que o PostgreSQL seja acessado
    # externamente através da porta 5433.
    ports:
      - "5433:5432"
    # Define que o container será sempre reiniciado automaticamente caso seja encerrado
    restart: always

  hello_docker_app:
    # Embora seja definida uma imagem chamada hello_docker_app, a diretiva
    # build: . indica que o Docker Compose deve construir a imagem usando o Dockerfile localizado no diretório atual.
    image: hello_docker_app
    # Especifica um nome personalizado para o container
    container_name: hello_docker_app
    # Construa a imagem a partir do Dockerfile localizado no diretório atual
    build: .
    # a porta 8000 exposta pelo container (onde o FastAPI normalmente escuta) é mapeada para a
    # porta 8001 do host. Assim, você acessará sua aplicação via http://localhost:8001
    ports:
      - "8001:8000"
    # Essa diretiva informa ao Docker Compose que o container da aplicação depende do container do
    # banco de dados. Dessa forma, o Compose inicia o hello_docker_db antes de iniciar o hello_docker_app.
    depends_on:
      - hello_docker_db

# Essa parte declara um volume nomeado chamado pgdata. Ele é referenciado no serviço do banco de
# dados para armazenar os dados de forma persistente
volumes:
  pgdata:
```

2. Na sequência, abra o terminal e execute o seguinte comando para executar os *containers*
definidos anteriormente:
```sh
docker compose up
```

3. Caso tudo tenha dado certo, a seguinte saída será mostrada no terminal:
```
hello_docker_db   | 
hello_docker_db   | PostgreSQL Database directory appears to contain a database; Skipping initialization
hello_docker_db   | 
hello_docker_db   | 2025-03-04 18:41:11.533 UTC [1] LOG:  starting PostgreSQL 17.3 (Debian 17.3-3.pgdg120+1) on x86_64-pc-linux-gnu, compiled by gcc (Debian 12.2.0-14) 12.2.0, 64-bit
hello_docker_db   | 2025-03-04 18:41:11.533 UTC [1] LOG:  listening on IPv4 address "0.0.0.0", port 5432
hello_docker_db   | 2025-03-04 18:41:11.533 UTC [1] LOG:  listening on IPv6 address "::", port 5432
hello_docker_db   | 2025-03-04 18:41:11.539 UTC [1] LOG:  listening on Unix socket "/var/run/postgresql/.s.PGSQL.5432"
hello_docker_db   | 2025-03-04 18:41:11.545 UTC [29] LOG:  database system was shut down at 2025-03-04 16:21:50 UTC
hello_docker_db   | 2025-03-04 18:41:11.553 UTC [1] LOG:  database system is ready to accept connections
hello_docker_app  | 
hello_docker_app  |    FastAPI   Starting production server 🚀
hello_docker_app  |  
hello_docker_app  |              Searching for package file structure from directories with 
hello_docker_app  |              __init__.py files
hello_docker_app  |              Importing from /code
hello_docker_app  |  
hello_docker_app  |     module   📁 app
hello_docker_app  |              ├── 🐍 __init__.py
hello_docker_app  |              └── 🐍 main.py
hello_docker_app  |  
hello_docker_app  |       code   Importing the FastAPI app object from the module with the following
hello_docker_app  |              code:
hello_docker_app  |  
hello_docker_app  |              from app.main import app
hello_docker_app  |  
hello_docker_app  |        app   Using import string: app.main:app
hello_docker_app  |  
hello_docker_app  |     server   Server started at http://0.0.0.0:8000
hello_docker_app  |     server   Documentation at http://0.0.0.0:8000/docs
hello_docker_app  |  
hello_docker_app  |              Logs:
hello_docker_app  |  
hello_docker_app  |       INFO   Started server process [1]
hello_docker_app  |       INFO   Waiting for application startup.
hello_docker_app  |       INFO   Application startup complete.
hello_docker_app  |       INFO   Uvicorn running on http://0.0.0.0:8000 (Press CTRL+C to quit)
```

4. Para parar a execução dos *containers*, pressione Ctrl + C e, na sequência, execute `docker compose down`
no terminal.