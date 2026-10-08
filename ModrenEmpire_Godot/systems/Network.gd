extends Node

signal peer_joined(id)
signal peer_left(id)
signal state_received(data)

var peer: ENetMultiplayerPeer
var session_code := ""
var is_host := false

func host(port:int=47777)->bool:
    peer=ENetMultiplayerPeer.new()
    var err=peer.create_server(port,8)
    if err != OK: return false
    multiplayer.multiplayer_peer=peer
    is_host=true
    session_code="ME-%d"%port
    Game.state.lan={"mode":"host","host":true,"connected":true,"session":session_code}
    return true

func join(ip:String,port:int=47777)->bool:
    peer=ENetMultiplayerPeer.new()
    var err=peer.create_client(ip,port)
    if err != OK: return false
    multiplayer.multiplayer_peer=peer
    is_host=false
    session_code="ME-%d"%port
    Game.state.lan={"mode":"client","host":false,"connected":true,"session":session_code}
    return true

@rpc("authority","call_local","reliable")
func sync_state(snapshot:Dictionary)->void:
    if not is_host: Game.state=snapshot; Game.changed.emit(); state_received.emit(snapshot)

func broadcast_state()->void:
    if is_host: sync_state.rpc(Game.state)

func leave()->void:
    multiplayer.multiplayer_peer=null
    Game.state.lan={"mode":"offline","host":false,"connected":false,"session":""}
