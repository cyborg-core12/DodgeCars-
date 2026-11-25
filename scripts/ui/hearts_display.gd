extends Control

# Cœurs des vies

var max_lives = 3
var lives = 3


func set_max_lives(value: int):
	max_lives = value
	queue_redraw()


func set_lives(value: int):
	if value != lives:
		lives = value
		queue_redraw()


func _draw():
	for i in max_lives:
		var color = UIStyle.RED if i < lives else Color(1, 1, 1, 0.15)
		UIStyle.draw_heart(self, Vector2(18 + i * 36, 21), 30, color)
