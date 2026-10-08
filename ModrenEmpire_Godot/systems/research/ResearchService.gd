extends RefCounted
class_name ResearchService
func total_levels()->int:
    var n:=0
    for v in Game.state.research.values(): n += int(v)
    return n
func strongest_area()->String:
    var best=""; var level=-1
    for k in Game.state.research.keys():
        if int(Game.state.research[k])>level: best=k; level=int(Game.state.research[k])
    return best
