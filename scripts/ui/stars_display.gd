extends Control

# Étoiles de l'écran de victoire

var stars = 0


func set_stars(value: int):
	stars = value
	queue_redraw()


func _draw():
	var center_x = size.x / 2
	for i in 3:
		var color = UIStyle.YELLOW if i < stars else Color(1, 1, 1, 0.15)
		UIStyle.draw_star(self, Vector2(center_x + (i - 1) * 62, size.y / 2), 26, color)
