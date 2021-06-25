
# App para uso offline integrado com o AWS AppSync   
Projeto de demonstração para aplicativos Flutter, que necessitam de um funcionamento offline e integrando quando existir uma conexão com a internet, através de uma API GraphQL.  
  
## Montando o ambiente
  
Antes de iniciar a instalação é necessário ter o [SAM](https://aws.amazon.com/pt/serverless/sam/), em seu sistema operacional para a criação do template no [CloudFormation](https://aws.amazon.com/pt/cloudformation/).
- Para criação do DynamoDB e AppSync pode ser utilizado o comando:  `sam deploy --guided --capabilities CAPABILITY_NAMED_IAM -t templates/template.yml`.
- Após o deploy do template é necessário acessar o arquivo `/lib/environment/environment.dart` dentro do projeto flutter e apontar o Endpoint e API_KEY do AppSync.
- Para execução do App importe o projeto para o Android Studio como projeto Flutter ou utilize a linha de comando, para mais detalhes verifique a documetação oficial do [Flutter](https://flutter.dev/docs/get-started/install).

## Conceitos
De forma minimalista, o aplicativo funciona inteiramente offline, salvando os dados em uma base SqLite e quando 
o estado de rede do dispositivo estiver online estas informações serão sincronizadas com a nuvem.

### Dados no SqLite
A base, de forma genérica contém quatro campos pricipais, que são responsáveis por todo o fluxo offline do usuário:
- ID: informação unica de cada elemento utilizando o UUID versão 4.
- last_modificated campo do tipo Datetime responsável por informar quando foi a última alteração nos dados.
- deleted campo Boolean para exclusões, pois o device pode estar offline no momento.
- sync campo Boolean informando se o dado ja foi sincronizado.

### Sincronia dos dados
Toda vez que o dispositivo estiver online, os dados serão enviados para o AppSync, com base no campo sync da base local e baixados do mesmo com base na data da ultima sincronização.

Para mais detalhes acesse a publicação no link(ainda sem link)