extends RefCounted
class_name StaffService
func average_skill()->float:
    if Game.state.staff.is_empty(): return 0.0
    var total:=0.0
    for e in Game.state.staff: total+=float(e.get("skill",0.0))
    return total/Game.state.staff.size()
func payroll()->float:
    var total:=0.0
    for e in Game.state.staff: total+=float(e.get("salary",0.0))
    return total
