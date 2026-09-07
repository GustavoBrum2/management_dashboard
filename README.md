# TwinMatch Gestão

Dashboard Flutter para gerenciar os Digital Twins publicados pelo [agente local](../local_agent).

O agente coleta o hardware da máquina, monta um Digital Twin e envia o snapshot atual para o Firebase Realtime Database. Este painel lê essa frota, mostra a configuração de cada máquina e reutiliza a engine de compatibilidade do agente para recomendar upgrades de RAM, SSD e GPU.

## Origem dos dados

- **Twins:** `https://twinmatch-659d6-default-rtdb.firebaseio.com/twins.json`
- **Catálogo:** arquivos em `assets/data/` copiados de `local_agent/src/data/` (RAM, GPU, SSD, CPU e HDD)

Cada twin remoto contém `machineId`, `name`, timestamps e o snapshot `current` com a `build` já normalizada pelo agente.

## Executar

```bash
flutter pub get
flutter run -d windows
```

Na tela inicial, a frota é carregada do Firebase. Abra um Digital Twin e use **Gerar recomendações** para consultar o catálogo local com as mesmas regras do agente.

## Stack

- Flutter / Dart
- HTTP REST do Firebase Realtime Database
- Engine de compatibilidade portada de `local_agent/src/domain/rules`
- Serviço de recomendação MVP portado de `local_agent/src/services/mvp-recommendation-service.ts`
