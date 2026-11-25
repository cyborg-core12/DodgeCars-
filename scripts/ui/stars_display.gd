extends Control

## Affiche 3 étoiles sur l'écran de victoire (jaunes = étoiles gagnées).

var stars = 0


# Change le nombre d'étoiles gagnées (0 à 3)
func set_stars(value: int):
	stars = value
	queue_redraw()


# Dessine les 3 étoiles côte à côte, au centre du nœud
func _draw():
	var center_x = size.x / 2
	for i in 3:
		var color = UIStyle.YELLOW if i < stars else Color(1, 1, 1, 0.15)
		UIStyle.draw_star(self, Vector2(center_x + (i - 1) * 62, size.y / 2), 26, color)
