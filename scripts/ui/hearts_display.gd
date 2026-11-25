extends Control

## Affiche les vies du joueur sous forme de cœurs (rouges = vies restantes).

var max_lives = 3
var lives = 3


# Change le nombre de cœurs affichés (2 ou 3 selon le niveau)
func set_max_lives(value: int):
	max_lives = value
	queue_redraw()


# Met à jour les vies restantes et redessine seulement si ça a changé
func set_lives(value: int):
	if value != lives:
		lives = value
		queue_redraw()


# Dessine un cœur par vie : rouge s'il reste, transparent s'il est perdu
func _draw():
	for i in max_lives:
		var color = UIStyle.RED if i < lives else Color(1, 1, 1, 0.15)
		UIStyle.draw_heart(self, Vector2(18 + i * 36, 21), 30, color)
