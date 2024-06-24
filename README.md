# MobiRural

O MobiRural é um aplicativo desenvolvido em Flutter e integrado ao Firebase, projetado para melhorar a experiência de mobilidade na comunidade acadêmica, com foco especial em pessoas com deficiência física e visual. Oferecendo informações detalhadas sobre prédios no campus, rotas acessíveis, sinalização de obstáculos e recursos de favoritos.

## Índice

- [Visão Geral](#visão-geral)
- [Capturas de Tela](#capturas-de-tela)
- [Tecnologias Utilizadas](#tecnologias-utilizadas)
- [Instalação](#instalação)

## Visão Geral

Uma das características distintivas do MobiRural é a sua funcionalidade de rotas acessíveis, impulsionada API do Google. A funcionalidade permite aos usuários planejar e navegar por trajetos otimizados, levando em consideração a acessibilidade, como rampas, banheiros adaptados e elevadores. O aplicativo se torna um guia essencial para garantir que todos os membros da comunidade acadêmica possam se movimentar pelo campus de maneira eficiente e segura.
Além disso, o MobiRural oferece recursos abrangentes, como detalhes sobre prédios, sinalização de obstáculos, favoritos personalizáveis e a capacidade de deixar avaliações e comentários sobre a acessibilidade dos locais. Essas funcionalidades colaboram para a construção de um ambiente mais inclusivo e informado, proporcionando uma mobilidade tranquila para todos os usuários.

## Capturas de Tela

⚠️Em breve prints do Fluxo do APP⚠️

## Tecnologias Utilizadas

- Flutter
- GCP
- Firebase

## Instalação

Para rodar o projeto localmente:

 - Clone o projeto
```bash
git clone https://github.com/Filipelion/mobi-rural
```

 - Instale as dependências 
 ```bash
  flutter pub get
```

- Configure a API do Maps e Routes do Google:
    - na Google Cloud Platform obtenha as credenciais para utilizar a API
    - Substitua a chave API em:
        ```bash
        1 - android\app\src\main\AndroidManifest.xml
        2 - lib\utils\directions.dart
        ```
    - Em ambos os arquivos troque "CHAVE_API" pela credencial obtida.
