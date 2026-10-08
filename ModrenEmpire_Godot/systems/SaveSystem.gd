extends Node

const PATH := "user://modren_empire_save.json"

func save_game(path:String=PATH)->bool:
    var f=FileAccess.open(path,FileAccess.WRITE)
    if f==null: return false
    f.store_string(JSON.stringify(Game.state))
    f.close()
    return true

func load_game(path:String=PATH)->bool:
    if not FileAccess.file_exists(path): return false
    var f=FileAccess.open(path,FileAccess.READ)
    var parsed=JSON.parse_string(f.get_as_text())
    f.close()
    if typeof(parsed)!=TYPE_DICTIONARY: return false
    Game.state=parsed
    migrate()
    Game.changed.emit()
    return true

func export_save()->String: return JSON.stringify(Game.state)

func import_save(raw:String)->bool:
    var parsed=JSON.parse_string(raw)
    if typeof(parsed)!=TYPE_DICTIONARY: return false
    Game.state=parsed
    migrate()
    Game.changed.emit()
    return true

func migrate()->void:
    if not Game.state.has("version"): Game.state.version=1
    if not Game.state.has("bank"): Game.state.bank={"provider":"LOCAL_VIRTUAL_BANK","accounts":[],"transactions":[]}
    if not Game.state.has("wallet"): Game.state.wallet={"MECR":0.0,"MECOIN":0.0,"locked":0.0}
    Game.state.version=Game.SAVE_VERSION
