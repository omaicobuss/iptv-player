
---

## 📄 Arquivo 3: `prompt-inicial.md` (Prompt para iniciar no VS Code)

```markdown
# 🚀 Prompt Inicial - Setup do Projeto IPTV Player

> **Como usar:** Copie este prompt e cole no chat da sua IA de programação (Cursor, GitHub Copilot Chat, Claude, etc.) dentro do VS Code, após clonar este repositório e ter o Docker rodando.

---

## 📋 Prompt para Copiar
Olá! Vou iniciar um projeto de app IPTV em Flutter e preciso da sua ajuda para configurar o ambiente e criar a estrutura inicial.
📌 Contexto do Projeto
Tipo: App multiplataforma para reprodução de IPTV via listas M3U
Stack: Flutter 3.24+ com Dart 3.5+, MediaKit, Riverpod, Hive
Arquitetura: Clean Architecture com feature-first folder structure
Ambiente: Container Docker (NADA deve ser instalado no host)
📚 Documentação de Referência
Antes de começar, leia com atenção estes arquivos do projeto:
guia-desenvolvimento.md - Stack, requisitos e padrões
agents.md - Agentes e fluxo de trabalho
🎯 Tarefas Iniciais (nesta ordem)
Tarefa 1 - Validação do Ambiente Docker
Verifique se o Dockerfile.dev e docker-compose.yml estão corretos
Execute docker compose up -d e confirme que o container sobe sem erros
Entre no container com docker compose exec flutter-dev bash
Valide que flutter --version funciona dentro do container
Tarefa 2 - Criação do Projeto Flutter
Dentro do container, execute:
flutter create --org com.iptvplayer --project-name iptv_player .
Configure o pubspec.yaml com as dependências listadas no guia de desenvolvimento.
Tarefa 3 - Estrutura de Pastas
Crie a estrutura de pastas conforme definido no guia:
lib/
├── app/
│   ├── routes/
│   ├── theme/
│   └── di/
├── core/
│   ├── errors/
│   ├── utils/
│   ├── constants/
│   └── widgets/
├── features/
│   ├── playlist/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   ├── player/
│   ├── channel/
│   └── favorites/
└── main.dart
Tarefa 4 - Configuração do Lint
Configure o analysis_options.yaml com regras estritas
Garanta que flutter analyze rode sem erros
Tarefa 5 - Estrutura Base do main.dart
Crie um main.dart mínimo com:
Inicialização do MediaKit (MediaKit.ensureInitialized())
Configuração do ProviderScope (Riverpod)
MaterialApp com tema básico e go_router
Tela inicial placeholder ("IPTV Player - Em desenvolvimento")
Tarefa 6 - Primeiro Parser M3U (Prova de Conceito)
Implemente em lib/core/utils/m3u_parser.dart:
Função List<Channel> parseM3U(String content)
Deve extrair: name, logo, group, url
Tratar listas malformadas sem quebrar
Criar testes unitários em test/core/utils/m3u_parser_test.dart
Tarefa 7 - Commit Inicial
Crie um commit inicial seguindo conventional commits:
git init
git add .
git commit -m "chore: initial project setup with clean architecture structure"

✅ Critérios de Aceite
Container Docker rodando sem erros
flutter analyze sem erros
flutter test passando com os testes do parser
Estrutura de pastas criada conforme guia
main.dart rodando (mesmo que com tela simples)
⚠️ Restrições Importantes
NÃO instale nada no host - tudo dentro do container Docker
NÃO pule etapas - siga a ordem das tarefas
NÃO adicione dependências não listadas no guia sem justificar
SIM comente o código em português
SIM siga os padrões de nomenclatura do guia
📤 Formato de Resposta Esperado
Para cada tarefa, me entregue:
O código/arquivo criado (completo, não truncado)
Comandos executados e saída esperada
Pontos de atenção ou decisões tomadas
Confirmação de que os critérios de aceite foram atendidos
Vamos começar pela Tarefa 1 - validação do ambiente Docker. Me mostre o passo a passo completo.
