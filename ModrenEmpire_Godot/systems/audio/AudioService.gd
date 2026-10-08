extends Node
class_name AudioService
var enabled:=true
func play_feedback(stream:AudioStream)->void:
    if not enabled: return
    var p=AudioStreamPlayer.new(); p.stream=stream; add_child(p); p.play(); p.finished.connect(p.queue_free)
