
# App para uso offline integrado com o AWS AppSync   
Projeto de demonstração para aplicativos Flutter, que necessitam de um funcionamento offline e integrando quando existir uma conexão com a internet, através de uma API GraphQL.  
  
## Montando o ambiente
  
Antes de iniciar a instalação é necessário ter o [SAM](https://aws.amazon.com/pt/serverless/sam/), em seu sistema operacional para a criação do template via [CloudFormation](https://aws.amazon.com/pt/cloudformation/).
- Para criação do DynamoDB e AppSync pode ser utilizado o comando:  `sam deploy --guided --capabilities CAPABILITY_NAMED_IAM -t templates/template.yml`
