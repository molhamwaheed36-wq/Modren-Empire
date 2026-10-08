extends RefCounted
class_name MarketService
func unlocked_count()->int:
    var n:=0
    for m in Game.state.markets.values():
        if bool(m.get("unlocked",false)): n+=1
    return n
func total_demand()->float:
    var n:=0.0
    for m in Game.state.markets.values():
        if bool(m.get("unlocked",false)): n+=float(m.get("demand",0.0))
    return n
