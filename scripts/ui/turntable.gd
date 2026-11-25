extends Node2D

## Plateau tournant et projecteur sous la voiture, dans le garage.
## Le nœud est placé au centre de la voiture.

var color = Color.WHITE   # couleur de la voiture affichée
var time = 0.0


# À chaque image : le plateau tourne
func _process(delta):
	time += delta
	queue_redraw()


# Dessine le faisceau du projecteur, le halo coloré et le plateau
func _draw():
	# Faisceau du projecteur (part du haut de l'écran)
	draw_colored_polygon(PackedVector2Array([
		Vector2(-40, -174), Vector2(40, -174), Vector2(180, 150), Vector2(-180, 150),
	]), Color(1, 1, 1, 0.04))
	# Halo coloré
	draw_circle(Vector2.ZERO, 175, Color(color, 0.10))
	draw_circle(Vector2.ZERO, 158, Color(color, 0.12))
	# Plateau
	draw_circle(Vector2.ZERO, 145, Color(0.1, 0.11, 0.18, 0.95))
	draw_arc(Vector2.ZERO, 145, 0, TAU, 64, Color(color, 0.9), 3)
	draw_arc(Vector2.ZERO, 118, 0, TAU, 64, Color(1, 1, 1, 0.08), 2)
	# Petits traits qui tournent
	for i in 24:
		var angle = time * 0.6 + i * TAU / 24.0
		draw_arc(Vector2.ZERO, 132, angle, angle + 0.12, 4, Color(color, 0.7), 4)
