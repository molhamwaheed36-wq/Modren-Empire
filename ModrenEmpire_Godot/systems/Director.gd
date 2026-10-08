extends Node

func has_permission(permission:String)->bool:
    return Game.state.director.permissions.has("*") or Game.state.director.permissions.has(permission)

func inject_cash(amount:float)->void:
    if has_permission("economy"):
        Game.state.company.cash += max(0,amount)
        Game.log("DIRECTOR: cash injection %.0f"%amount)

func max_reputation()->void:
    if has_permission("economy"): Game.state.company.reputation=100.0; Game.changed.emit()

func boost_research(amount:int=5)->void:
    if not has_permission("research"): return
    for k in Game.state.research.keys(): Game.state.research[k]=max(int(Game.state.research[k]),amount)
    Game.log("DIRECTOR: research boosted")

func unlock_all_markets()->void:
    if not has_permission("markets"): return
    for k in Game.state.markets.keys(): Game.state.markets[k].unlocked=true
    Game.log("DIRECTOR: all markets unlocked")
