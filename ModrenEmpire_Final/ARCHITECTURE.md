# Architecture

## Runtime layers

1. **Android shell** — `MainActivity.kt` creates the WebView, exposes `ModrenLAN`, owns lifecycle cleanup and loads the local asset.
2. **Game UI and simulation** — `app/src/main/assets/game/index.html` contains responsive UI, validated state schema, commands and the monthly simulation loop.
3. **Persistence** — WebView `localStorage` stores schema v3. Export/import uses JSON and rejects files without the required schema markers.
4. **LAN transport** — `LanBridge.kt` provides host/client TCP transport only. The HTML protocol carries JSON state snapshots; the host is authoritative.
5. **Integration boundaries** — virtual banking is deliberately local and exposes adapter-shaped operations without real-money side effects.

## State ownership

`G` is the single game state object. Mutations happen through commands such as `doResearch`, `make`, `month`, `bank`, and `director`. Every command updates the activity log and re-renders. The monthly tick is the only automatic economy step.

## Extensibility

- Add products by extending `product` with a category and a component definition map.
- Add research by adding a node to `defs` with cost and prerequisite IDs.
- Replace the local bank through the contract in `BANK_INTEGRATION_CONTRACT.md`; do not call network/payment APIs from the simulation directly.
- Replace LAN transport without changing UI messages as long as `poll()`, `send()`, `startHost()`, and `connect()` remain available.
