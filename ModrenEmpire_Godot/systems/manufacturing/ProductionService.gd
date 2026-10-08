extends RefCounted
class_name ProductionService
func capacity()->int:
    var f=Game.state.factory
    return int(float(f.capacity)*float(f.efficiency)*float(max(1,f.plants)))
func queue_units(units:int)->void:
    Game.state.factory.queue += max(0,units)
