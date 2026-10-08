extends RefCounted
class_name CompetitionService
func strongest()->String:
    var best=""; var score=-INF
    for k in Game.state.competitors.keys():
        var c=Game.state.competitors[k]; var s=float(c.tech)*.5+float(c.marketing)*.3+float(c.share)*.2
        if s>score: score=s; best=k
    return best
