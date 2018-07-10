# Shipping cost API

## Requisitos de ambiente

#### Principais dependências

* Ruby 2.5.1
* Rails 5.2
* [dijkstra.gem](https://github.com/oscartanner/dijkstra.gem)
* PostgreSQL
* Redis

### Instalação e configuração

* 1\. Instale o [PostgreSQL](https://www.postgresql.org/docs/10/static/tutorial-install.html).
  1. Crie um usuário para o postgres. Ex: `sudo -u postgres createuser $USER`
* 2\. Instale o [Redis](https://redis.io/topics/quickstart).
* 3\. Instale o Ruby. Exemplo com [rvm](https://rvm.io/rvm/install): `rvm install 2.5.1`
* 4\. Instale o Bundler. `gem install bundler --no-ri --no-rdoc`
* 5\. Faça clone do projeto. `git clone https://github.com/serradura/backend-code-challenge.git`
* 6\. Acesse o projeto. Ex: `cd backend-code-challenge`
* 7\. Garanta que os serviços do postgres e redis estejam rodando. Ex: `ps aux | grep -E (redis|postgres)`
* 8\. Execute `bin/setup`. O comando irá:
  1. Instalar as dependências do projeto
  2. Configurar o banco de dados
  3. Gerar git hook responsável por verificar a qualidade e segurança do projeto antes que um `git push` ocorra.

### Execução dos testes

```
  bundle exec rspec
```

PS: Aplico uma abordagem relacionada ao conceito [Let's not](https://robots.thoughtbot.com/lets-not).

### Verificação da saúde do projeto

```
  bundle exec rake health
```

Resumo do comando acima:
- Executa os testes. Via: `rspec`.
- Gera relatório de cobertura de testes. Via: `simplecov` (pasta `coverage`).
- Verifica se há alguma vulnerabilidade nas dependências. Via: `bundle-audit` e `brakeman`.
- Faz uma verificação estática quanto a qualidade e padrões do codebase. Via: `rubocop` e `rubycritic` (pasta `tmp/rubycritic`).

PS: Esse comando será executado antes que um `git push` aconteça. Em caso de haver inconsistências o processo de push será interrompido.

PS.2: Caso não tenha executado `bin/setup`, execute `bin/setup-git-hooks` para garantir que o arquivo de hook exista.

---

## Sobre o desenvolvimento deste projeto

## Funcionalidades

### Recursos

**POST /distance**

Cria ou atualiza pontos de distribuição.

*Requisição:*

body:

String contendo 3 dados delimitados por espaço. Posições:
1. Origem (origin)
2. Destino (destination)
3. Distância (distance), valor numérico entre 1 e 100000.

Ex: 'A B 10'

*Respostas:*
* 204 - Ponto de distribuição criado ou atualizado com sucesso.
* 400 - Parâmetros inválidos.

PS: Todas as respostas retornam um body vazio.

Exemplos:
```shell
# Parâmetros válidos
curl -X POST http://localhost:3000/distance --data 'A B 20'
curl -X POST http://localhost:3000/distance --data 'A B 20.5'

# Parâmetros inválidos
curl -X POST http://localhost:3000/distance --data ''
curl -X POST http://localhost:3000/distance --data 'A'
curl -X POST http://localhost:3000/distance --data 'A B'
curl -X POST http://localhost:3000/distance --data 'A B C'
curl -X POST http://localhost:3000/distance --data 'A B 30.'
```

**GET /cost**

Calcula o custo de entrega considerando o trajeto de menor distância.

*Requisição:*

Parâmetros permitidos
* origin (Origem)
* destination (Destino)
* weight (Peso), valor numérico entre 1 e 50.

*Respostas:*
* 200 - Valor calculado. Body: String com valor no seguinte formato `\d+\.\d{1,2}`.
* 400 - Parâmetros inválidos. Body: Vazio
* 404 - Origem e/ou destino não encontrado. Body: Vazio

Exemplos:
```shell
# Parâmetros válidos
curl -X GET http://localhost:3000/cost\?origin\=A\&destination\=D\&weight\=5

# Parâmetros inválidos
curl -X GET http://localhost:3000/cost\?origin\=A\&destination\=D\&weight\=0
curl -X GET http://localhost:3000/cost\?origin\=A\&destination\=D\&weight\=51
curl -X GET http://localhost:3000/cost\?origin\=A\&destination\=D
```

### Arquitetura

MVC orientado a SOLID. Como? Respeitando a estrutura padrão do Rails e utilizando princípios funcionais para ter um codebase orientado a composição.

**Como assim princípios funcionais?**

Uma função pode ser definida como um mapeamento de uma entrada (input) para uma saída (output). Ou seja, a saída é determinada pela entrada que a função recebe.

**O que isso tem haver com SOLID?**

Muito, afinal:
- Uma função deve fazer uma única coisa (SRP).
- Uma função deve receber outras funções para compor uma computação/resultado mais complexo (OCP).
- Composição leva a injeção/inversão de dependência.

**Como princípios funcionais foram aplicados?**

O Functional First Development (FFD) foi o principal guideline. Suas duas regras são:
1. First, code everything you can without side effects.
2. Then, code your side effects.

**Algo foi utilizado para facilitar o FFD?**

Sim, o [`dry-transaction`](http://dry-rb.org/gems/dry-transaction/). Basicamente utilizei o mesmo como uma camada de services.

**Qual o valor que o dry-transaction traz para a aplicação?**

São três:

1. Todo side-effect de escrita e atualização é concentrado nele. Ou seja, não há nenhum ponto da aplicação que modifique o estado do sistema que não eles.
2. Dado o ponto anterior, ganhamos o fato de que toda e qualquer exceção/inconsistência de regra de negócio estará contida em uma transaction.
3. Todas as operações de side-effects estão nas últimas etapas (step) das transactions. Ou seja, o side-effect será produto da computação realizada anteriormente. Assim sendo, todo estado inconsistente (ouput) terá uma relação direta com a transformação (funções puras) ocorridas nas computações realizadas antes do output/etapa final.

PS: Uma consequência natural da abordagem acima é que os models passam a ser somente leitura, já que os side-effects que mutam o estado estão concentrados nas transactions.

PS.2: Acessar/Ler um banco de dados é um side-effect.

**Outra dependência relevante foi utilizada ?**

Sim, o [`dry-types`](http://dry-rb.org/gems/dry-types/) e o [`dry-validation`](http://dry-rb.org/gems/dry-validation). Motivo: Se o output de uma função é produto do input, quanto mais garantido for o input melhores serão as garantias (corretude) do output.

PS: Verifique `app/models/types.rb`

### Possíveis melhorias

* Otimizar o uso do algoritmo dijkstra. Ex: Realizar benchmark com outras implementações, utilizar [Neo4J](https://neo4j.com/blog/graph-compute-neo4j-algorithms-spark-extensions/).
* Dependendo da estratégia acima e a continuidade do uso do Redis, fazer uso [do LRU cache](https://redis.io/topics/lru-cache) para gerenciar o volume de dados em cache.
* Garantir a existência dos pontos de origem e destino antes de tentar calcular o custo (GET /cost) quando a requisição receber parâmetros válidos.
* Configurar CI (Travis), monitoramento (New Relic), error tracker (Airbrake), qualidade (Codeclimate).

---

Ruby/Elixir Engineer Coding Challenge
=======================

Hello!

We've come up with this relatively open-ended programming/engineering challenge that will allow you to demonstrate your skills from the comfort of your own workspace. In addition, we know your time is valuable, so please feel free to use your completed work as a portfolio piece.

We wish you the best of luck and can't wait to see what you create!

## Overview

Your goal is to develop a system to calculate the shipping cost for products of an order, based on it's weight and distance from origin to destination. The distribution points will be supplied to this system throught an API and the shipping cost will be calculated in another API, always aiming at the lowest cost to the customer.

To populate the database, another system will call the API informing the distance (in kilometers) between *origin* and *destination* of two distribution points. For example:
```
POST /distance
A B 10
```
```
POST /distance
B C 15
```
```
POST /distance
A C 30
```

In a second moment, the shopping system will call the API informing the total weight of the order, the source and destination points. The system should return the lowest shipping cost, using the formula: `cost = distance * weight * 0.15`. For example:

```
GET /cost?origin=A&destination=C&weight=5
18.75
```

Explanation: the shortest path from A to C is A -> B -> C = 25km. `cost = 25 * 5 * 0.15 = 18.75`

## Considerations

* The input format of distance should have the format `A B X`, where *0 < X <= 100000*. Wrong format or data should return an error;
* If a distance point already exists, should be replaced with the new value;
* The cost API should validate the given points and weight, where *0 < wheight <= 50*. If no path was found between *origin*  and *destination*, an error should be returned;
* The solution should be implemented in Ruby or Elixir. You could use the frameworks that you're most used to.
* Both APIs will receive a large amount of requests: choose the design and technology wisely;

## Submission

You can follow the GitHub Fork/Pull Request workflow by [forking this repository](https://github.com/RakutenBrasil/backend-code-challenge/fork), commiting your changes, and submiting a pull request to us, explaning your solution, technical decisions and how configure/use on the README file. For more information about that, you can see this [GitHub article](https://help.github.com/articles/fork-a-repo/#propose-changes-to-someone-elses-project).

## What we are looking for

We are looking for several things with this challenge. First, of course, we're looking for your answer to be technically correct. Beyond that, we're also looking for:

* Is your code easy to read and understand?
* Are you following the usual conventions for Ruby/Elixir development?
* How good are you at writing tests? And how easy are they to read and understand?
* Did you follow these directions?

We will of course **examine your code to see its correctness, readability, general elegance, architectural decisions, and modularity**. If/when you meet with us, be prepared to talk about why and how you design your solution. We also test your system with a large amount of data to mesure the performance and to see if we can break stuff.

That's it. There aren't any hidden gotchas or trick questions. That's really what we're going to do.

## License

We have licensed this project under the MIT license so that you may use this for a portfolio piece (or anything else!).
