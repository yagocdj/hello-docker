# Guia de Prática: Kubernetes

## Objetivo

Este guia tem como objetivo ensinar como usar comandos básicos do Kubernetes para implantar e gerenciar aplicações containerizadas. O foco é entender o fluxo geral e o propósito dos comandos, não em criar uma aplicação específica.

## Mãos à obra

## 1. Instalando as dependências

Instale o kubectl, que servirá como uma CLI para manusear o kubernetes.
```sh
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/
```

Instale o Kind, utilizado para criar o cluster que iremos utilizar para a prática.
```sh
curl -Lo ./kind https://kind.sigs.k8s.io/dl/latest/kind-linux-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/
```

## 2. Criando cluster

Gere o cluster que usaremos para nossa prática utilizando o kind.
```sh
kind create cluster
```

## 3. Gerando a Configuração do Deployment (YAML)

```sh
kubectl create deployment hello-docker --image=yagocesar/hello-docker:1.0 --replicas=5 --dry-run=client -o yaml > deployment.yaml
```

### O quê este comando faz?  

- `kubectl create deployment`: Informando ao Kubernetes que você quer rodar a sua aplicação.

- `--image yagocesar/hello-docker:1.0`: Define qual imagem Docker será executada.

- `--replicas=5`: Define que o deployment deve estar sempre rodando no mínio 5 replicas.

- `--dry-run`: Ao invés de criar o deployment *de verdade*, ele te mostra como seria a configuração.

- `-o yaml` :  Formata a saída do comando para o formato YAML.

- `> deployment.yaml`: Redireciona a saída do comando para o arquivo `deployment.yaml`. Essa configuração serve como base para realizar o deployment da aplicação.

## 4. Aplicando a Configuração do Deployment

Agora que já temos as configurações salvas para fácil manutenção ou edição, iremos utilizá-las para gerar o deployment.
```sh
kubectl apply -f deployment.yaml
```

## 5. Verificando a Criação do Deployment e seus Pods

Verifique se o deployment e seu pods foram criados com sucesso.
```sh
kubectl get deployments
kubectl get pod
```

## 6. Crie um service para o pod

Como os ips dos pods são dinâmicos, precisamos criar uma maneira de se conectar ao nosso pod fixa. Os services servem justamente como um IP estático que gerenciam as requisições pra ele mandadas, e encaminha elas para o pod apropriado.
```sh
kubectl expose deployment hello-docker --port 8000 --target-port 8000
```

Após isso, é necessário copiar o IP deste service para posteriormente nos conectarmos com os pods. Você pode fazer isso rodando o seguinte código:
```sh
kubectl get svc
```

Copie o IP para utilizá-lo em passos futuros.

## 7. Instancie um novo Pod

Abra uma aba nova no terminal e execute o seguinte código:
```sh
kubectl run --image alpine -it demo sh
```

### O quê este comando faz?  

Instancia um novo pod rodando a imagem "alpine", e abre o shell desse pod no terminal atual. Utilizaremos esse pod para se comunicar com os outros pods do nosso deployment.

## 7. Instale o curl no novo pod

```sh
apk add curl
```

## 8. Use o curl para se conectar à um pod do hello-docker

```sh
curl hello-world:8000
```

Saída esperada:
```sh
{"Hello":"World"}/ #
```
