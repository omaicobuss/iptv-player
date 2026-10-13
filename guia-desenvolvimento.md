# 📺 Guia de Desenvolvimento - App IPTV Player

> **Versão:** 1.0.0  
> **Data de criação:** 13/10/2026  
> **Status:** Em planejamento

---

## 1. 🎯 Visão Geral do Projeto

### 1.1 Descrição
Aplicativo multiplataforma para reprodução de conteúdo IPTV a partir de listas `.m3u` / `.m3u8` fornecidas pelo usuário. O app atua exclusivamente como **reprodutor (player)**, sem hospedar ou distribuir qualquer conteúdo.

### 1.2 Plataformas Alvo
- 📱 Android (celulares e tablets)
- 🍎 iOS
- 📺 Android TV / Google TV
- 🔥 Amazon Fire TV / FireStick
- 💻 Windows / macOS / Linux (Desktop)
- 🌐 Web (futuro, com limitações de codec)

### 1.3 Objetivos Principais
1. Permitir importação de listas via **arquivo local** ou **URL remota**
2. Reproduzir streams em formatos HLS, MPEG-TS, RTMP e MP4
3. Organizar canais por categorias (group-title)
4. Suportar listas com dezenas de milhares de canais sem travar
5. Interface adaptável para toque (mobile) e controle remoto (TV)

---

## 2. 🛠️ Stack Tecnológica

### 2.1 Core
| Tecnologia | Versão | Função |
|------------|--------|--------|
| Flutter | 3.24+ | Framework multiplataforma |
| Dart | 3.5+ | Linguagem |
| Kotlin / Swift | - | Código nativo (quando necessário) |

### 2.2 Dependências Principais
| Pacote | Função |
|--------|--------|
| `media_kit` + `media_kit_video` | Player de vídeo (baseado em mpv) |
| `media_kit_libs_video` | Codecs nativos para todas as plataformas |
| `m3u_parser` ou regex custom | Parser de listas M3U |
| `hive_ce` | Banco de dados local (listas salvas) |
| `dio` | Cliente HTTP para baixar listas/EPG |
| `file_picker` | Seleção de arquivos locais |
| `flutter_riverpod` | Gerenciamento de estado |
| `go_router` | Navegação entre telas |
| `xml` | Parser de EPG (XMLTV) - Fase 2 |
| `cached_network_image` | Cache de logos dos canais |
| `shared_preferences` | Configurações do usuário |

### 2.3 Dev Dependencies
| Pacote | Função |
|--------|--------|
| `flutter_lints` | Regras de lint |
| `mocktail` | Mocks para testes |
| `integration_test` | Testes de integração |

---

## 3. 📋 Requisitos

### 3.1 Funcionais (RF)
- **RF01** - Importar lista M3U via URL (HTTP/HTTPS)
- **RF02** - Importar lista M3U via arquivo local (.m3u, .m3u8, .txt)
- **RF03** - Listar canais agrupados por categoria (group-title)
- **RF04** - Buscar canais por nome (search)
- **RF05** - Reproduzir stream ao vivo com player customizado
- **RF06** - Exibir logo do canal (tvg-logo)
- **RF07** - Salvar listas importadas localmente
- **RF08** - Favoritar canais
- **RF09** - Histórico de canais assistidos
- **RF10** - Suporte a EPG (Guia de Programação) - *Fase 2*
- **RF11** - Suporte a múltiplas playlists simultâneas

### 3.2 Não-Funcionais (RNF)
- **RNF01** - Performance: UI deve manter 60fps mesmo com 10.000+ canais
- **RNF02** - Latência: início de reprodução em < 3s em redes boas
- **RNF03** - Consumo de memória: < 300MB em operação normal
- **RNF04** - Navegação por D-Pad (controle remoto) em TVs
- **RNF05** - Suporte a modo escuro/claro
- **RNF06** - Internacionalização (i18n) - PT-BR e EN
- **RNF07** - Offline-first: listas salvas funcionam sem internet

---

## 4. 🏗️ Arquitetura

### 4.1 Padrão Arquitetural
**Clean Architecture + Feature-First Folder Structure**
lib/
├── app/ # Configurações globais
│ ├── routes/
│ ├── theme/
│ └── di/ # Injeção de dependência
├── core/ # Código compartilhado
│ ├── errors/
│ ├── utils/
│ ├── constants/
│ └── widgets/ # Widgets genéricos reutilizáveis
├── features/ # Features organizadas por domínio
│ ├── playlist/ # Gerenciamento de playlists
│ │ ├── data/ # Repositories, datasources, models
│ │ ├── domain/ # Entities, usecases, interfaces
│ │ └── presentation/ # Screens, widgets, providers
│ ├── player/ # Reprodução de vídeo
│ ├── channel/ # Listagem e busca de canais
│ ├── favorites/ # Favoritos
│ └── epg/ # Guia de programação (Fase 2)
└── main.dart


### 4.2 Camadas
1. **Presentation (UI)** → Riverpod Providers + Widgets
2. **Domain** → UseCases, Entities, Repository Interfaces
3. **Data** → Repository Implementations, DataSources (local/remote), DTOs

### 4.3 Padrões de Projeto Utilizados
- **Repository Pattern** - Abstração da fonte de dados
- **Use Case Pattern** - Casos de uso isolados e testáveis
- **Provider Pattern** (Riverpod) - State management
- **Factory Pattern** - Criação de instâncias complexas (Player)
- **Singleton** - Instâncias globais (Player do MediaKit)
- **Adapter Pattern** - Conversão entre DTOs e Entities

---

## 5. 🎨 Padrões de Código

### 5.1 Nomenclatura
- **Arquivos:** `snake_case.dart` (ex: `channel_list_screen.dart`)
- **Classes:** `PascalCase` (ex: `ChannelListScreen`)
- **Variáveis/Funções:** `camelCase` (ex: `loadChannels()`)
- **Constantes:** `camelCase` (ex: `maxRetryAttempts`)
- **Providers:** `camelCaseProvider` (ex: `channelListProvider`)

### 5.2 Estrutura de um Provider (Riverpod)
```dart
@riverpod
Future<List<Channel>> channels(ChannelsRef ref) async {
  final repository = ref.watch(playlistRepositoryProvider);
  return repository.getAllChannels();
}

### 5.3 Commits (Conventional Commits)
feat: adiciona parser de listas M3U
fix: corrige travamento em listas com +10k canais
refactor: move lógica de busca para usecase
docs: atualiza README com instruções de setup
test: adiciona testes para o parser M3U
chore: atualiza dependências do Flutter

### 5.4 Regras de Lint
flutter_lints com regras estritas
Linhas máximas: 100 caracteres
Sem print() em produção (usar logger)
Todos os widgets públicos devem ter documentação

## 6 Ambiente Docker

### 6.1 Por que Docker?
Evitar instalação direta de Flutter, Android SDK, JDK e ferramentas no host. Garante ambiente idêntico entre desenvolvedores e CI.

### 6.2 Imagem Base Recomendada
# Dockerfile.dev
FROM ghcr.io/cirruslabs/flutter:3.24.5

# Instala dependências do sistema necessárias
RUN apt-get update && apt-get install -y \
    clang cmake ninja-build pkg-config \
    libgtk-3-dev liblzma-dev \
    && rm -rf /var/lib/apt/lists/*

# Configura Android SDK (para builds Android/TV)
ENV ANDROID_HOME=/opt/android-sdk
ENV PATH="${PATH}:${ANDROID_HOME}/cmdline-tools/latest/bin:${ANDROID_HOME}/platform-tools"

# Aceita licenças do Android
RUN yes | sdkmanager --licenses || true

# Define workspace
WORKDIR /workspace

# Mantém container rodando
CMD ["tail", "-f", "/dev/null"]

### 6.3 Docker Compose
# docker-compose.yml
version: '3.8'

services:
  flutter-dev:
    build:
      context: .
      dockerfile: Dockerfile.dev
    container_name: iptv_flutter_dev
    volumes:
      - .:/workspace
      - flutter_cache:/root/.pub-cache
      - gradle_cache:/root/.gradle
    environment:
      - DISPLAY=${DISPLAY} # Para Linux (flutter run com GUI)
    network_mode: host
    stdin_open: true
    tty: true

volumes:
  flutter_cache:
  gradle_cache:

### 6.4 Comandos Úteis
# Iniciar ambiente
docker compose up -d

# Entrar no container
docker compose exec flutter-dev bash

# Criar projeto (primeira vez)
docker compose exec flutter-dev flutter create iptv_player

# Rodar em Android (com dispositivo conectado no host)
docker compose exec flutter-dev flutter run -d <device_id>

# Build APK release
docker compose exec flutter-dev flutter build apk --release

# Parar ambiente
docker compose down

## 7 Estratégia de Testes
Tipo
Cobertura Alvo
Ferramenta
Unitários
80%+
test, mocktail
Widget
Componentes críticos
flutter_test
Integração
Fluxos principais
integration_test
Prioridade de testes:
Parser de M3U (crítico)
Repositories
UseCases
Widgets complexos

## 8 Roadmap
Fase 1 - MVP (4 semanas)
Setup do projeto e Docker
Parser de M3U
Importação de lista (URL e arquivo)
Listagem de canais por categoria
Player básico com MediaKit
Persistência local (Hive)
Fase 2 - Polimento (3 semanas)
Busca de canais
Favoritos e histórico
Controles customizados do player
Navegação D-Pad para TV
Tema escuro/claro
Fase 3 - Avançado (4 semanas)
Suporte a EPG (XMLTV)
Múltiplas playlists
Picture-in-Picture
Chromecast / AirPlay
Publicação nas lojas

## 9 Referências 
Documentação Flutter https://docs.flutter.dev/?spm=a2ty_o01.29997173.0.0.3e32c921xljZJw
MediaKit GitHub https://github.com/media-kit/media-kit?spm=a2ty_o01.29997173.0.0.3e32c921xljZJw
Riverpod Docs https://riverpod.dev/?spm=a2ty_o01.29997173.0.0.3e32c921xljZJw
Especificação M3U https://en.wikipedia.org/wiki/M3U?spm=a2ty_o01.29997173.0.0.3e32c921xljZJw