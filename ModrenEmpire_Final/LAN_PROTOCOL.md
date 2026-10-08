# Local LAN Protocol

TCP port `47777` is used on the same Wi-Fi or phone hotspot. Messages are UTF-8 JSON lines.

```json
{"type":"request_state"}
{"type":"state","schema":3,"payload":{}}
```

A client requests a snapshot after connecting. The host replies with the complete schema-3 game state. Clients accept only schema 3. The host is authoritative, so conflict handling is host-wins rather than silent last-write-wins. `LanBridge.kt` has connection timeouts, queue polling, closed-client cleanup and Activity lifecycle shutdown. Physical multi-device validation still requires two Android devices on the same network.
