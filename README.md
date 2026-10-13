# IPTV Player

## Executar no navegador (Windows + Docker)

Abra um terminal na pasta do projeto e inicie o container:

```powershell
docker compose up -d --build
```

Inicie o servidor web do Flutter dentro do container:

```powershell
docker compose exec flutter-dev bash -lc "cd /workspace && flutter run -d web-server --web-hostname 0.0.0.0 --web-port 8081"
```

Mantenha esse terminal aberto e acesse <http://localhost:8081> no navegador do Windows.
Para parar o app, pressione `Ctrl+C`; para parar o container, execute `docker compose down`.

## Reprodução no navegador

O player web requer uma URL de streaming HTTP ou HTTPS. O servidor da transmissão
precisa estar acessível pelo navegador e permitir requisições cross-origin (CORS).
URLs RTSP/UDP e outros protocolos nativos não são reproduzíveis pelo navegador.
Os canais de demonstração usam URLs fictícias; importe uma playlist com streams ativos
para testar a reprodução.

## Persistência da playlist

Playlists importadas de arquivo ou URL são salvas localmente e restauradas quando o app
for aberto novamente. A lista só é substituída depois que uma nova playlist válida for
carregada; playlists vazias ou inválidas não apagam os canais já salvos. No navegador,
os dados ficam no armazenamento local do site e são removidos se os dados do site forem
limpos.

## Verificações

```powershell
docker compose exec flutter-dev bash -lc "cd /workspace && flutter analyze && flutter test"
```
