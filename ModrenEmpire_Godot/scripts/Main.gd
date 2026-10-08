extends Node2D

var ui: Control
var scene: Node2D

func _ready() -> void:
    ui = preload("res://ui/MainUI.gd").new()
    add_child(ui)
    ui.build(self)

func _process(delta: float) -> void:
    queue_redraw()

func _draw() -> void:
    draw_rect(Rect2(0,0,1280,720), Color("101521"))
    draw_rect(Rect2(0,0,1280,92), Color("172033"))
    # Stylized headquarters / factory / store scene.
    draw_rect(Rect2(560,250,290,250), Color("24324a"))
    draw_rect(Rect2(600,205,210,45), Color("355070"))
    draw_rect(Rect2(625,300,55,70), Color("6aa5c8"))
    draw_rect(Rect2(700,300,55,70), Color("6aa5c8"))
    draw_rect(Rect2(775,300,55,70), Color("6aa5c8"))
    draw_rect(Rect2(595,405,70,95), Color("4a596f"))
    draw_rect(Rect2(735,405,95,95), Color("4a596f"))
    draw_rect(Rect2(905,320,170,180), Color("283d35"))
    draw_rect(Rect2(925,350,130,65), Color("6c9c76"))
    draw_string(ThemeDB.fallback_font, Vector2(948,390), "MODREN STORE", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color.WHITE)
