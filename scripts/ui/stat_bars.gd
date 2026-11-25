extends Control

# Barres de stats du garage

const NAMES = ["MANIABILITÉ", "FINESSE", "PROTECTION"]

var values = [0.0, 0.0, 0.0]
var targets = [0.0, 0.0, 0.0]
var color = Color.WHITE


func set_stats(new_targets: Array, new_color: Color):
	targets = new_targets
	color = new_color


# Animation des barres
func _process(delta):
	for i in 3:
		values[i] = lerp(values[i], targets[i], 8 * delta)
	queue_redraw()


func _draw():
	for i in 3:
		var y = i * 30.0
		draw_string(UIStyle.font(), Vector2(0, y + 19), NAMES[i], HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color.WHITE)
		var bar = Rect2(140, y + 6, 240, 14)
		draw_style_box(UIStyle.make_box(Color(1, 1, 1, 0.1), 7), bar)
		if values[i] > 0.02:
			draw_style_box(UIStyle.make_box(color, 7), Rect2(bar.position, Vector2(bar.size.x * values[i], bar.size.y)))
