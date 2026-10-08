extends RefCounted
class_name EventService
func apply_cash_delta(delta:float)->void:
    Game.state.company.cash += delta
func apply_reputation_delta(delta:float)->void:
    Game.state.company.reputation=clamp(float(Game.state.company.reputation)+delta,0.0,100.0)
