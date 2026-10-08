extends RefCounted
class_name SupplyService
func reliability()->float:
    if Game.state.suppliers.is_empty(): return 0.0
    var total:=0.0
    for s in Game.state.suppliers: total += float(s.get("reliability",0.0))
    return total/Game.state.suppliers.size()
