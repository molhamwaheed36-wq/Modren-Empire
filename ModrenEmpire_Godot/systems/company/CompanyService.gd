extends RefCounted
class_name CompanyService
func value()->float:
    var s=Game.state
    return max(0.0,float(s.company.cash)-float(s.company.debt))+float(s.company.reputation)*10000.0+float(s.company.level)*25000.0
func add_xp(amount:float)->void:
    Game.state.company.xp += max(0.0,amount)
