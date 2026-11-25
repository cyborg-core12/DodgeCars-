extends Control

# Bonus actifs avec leur temps restant

var shield_time = 0.0
var magnet_time = 0.0


func update_times(shield: float, magnet: float):
	shield_time = shield
	magnet_time = magnet
	queue_redraw()


func _draw():
	var y = 0.0
	if shield_time > 0:
		_draw_pill(Vector2(0, y), "BOUCLIER  %d" % ceil(shield_time), UIStyle.BLUE)
		y += 44
	if magnet_time > 0:
		_draw_pill(Vector2(0, y), "AIMANT  %d" % ceil(magnet_time), UIStyle.RED)


func _draw_pill(pos: Vector2, text: String, color: Color):
	draw_style_box(UIStyle.make_box(Color(color, 0.9), 18), Rect2(pos, Vector2(170, 36)))
	draw_string(UIStyle.font(), pos + Vector2(14, 26), text, HORIZONTAL_ALIGNMENT_LEFT, -1, 18, UIStyle.DARK)
