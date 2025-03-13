# Guia de Prática: Kubernetes

## Objetivo
Este guia tem como objetivo ensinar os estudantes a utilizar Docker e Docker Compose para containerizar uma aplicação FastAPI. Os passos relacionados ao FastAPI serão explicados brevemente apenas para contextualizar.

## Pré-requisito
- Docker e Docker Compose instalados na máquina
- Conhecimentos básicos sobre linha de comando (utilize o sistema operacional de sua preferência)
- Python 3.12 instalado na máquina
- Um editor de texto da sua preferência

## Mãos à obra

### 1. Fazer o pull da imagem 
Primeiro pega a imagem do docker hub, foi uplodiada por Yago.
"Docker pull" da imagem
A imagem contem um node kubernetes com os conteineres


Instalar o Kind => Utilizado para rodar nodes kubernetes locais usando nodes de conteineres docker.

O kind ira criar uma imagem docker rodando esse node e seus conteineres

Kubctl => O kubectl é a ferramenta de linha de comando que será o cliente que se conectará com o node rodando no docker.

kubctl get nodes
kubctl get pod
kubctl get deployment
kubctl get replicaset
kubctl get pod

Gerar os nodes
gerar yaml?