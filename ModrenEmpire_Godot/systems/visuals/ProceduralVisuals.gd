extends Node2D
class_name ProceduralVisuals
func draw_company_scene()->void:
    queue_redraw()
func _draw()->void:
    draw_rect(Rect2(0,0,1280,720),Color("0b1020"))
    for i in range(8):
        var h=120+(i*43)%300
        draw_rect(Rect2(30+i*155,650-h,120,h),Color(0.08+0.01*i,0.12+0.01*i,0.20+0.01*i))
