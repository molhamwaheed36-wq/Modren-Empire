# LAN Protocol

Local co-op uses Godot ENet on port 47777. Host creates a session; clients join by LAN IP. State synchronization is reliable RPC-based and can be expanded into operation/delta messages. The architecture is local-network only; no public server is required.
