extends Control

## Barres de statistiques d'une voiture dans le garage (maniabilité, finesse, protection).
## Les barres se remplissent avec une petite animation.

const NAMES = ["MANIABILITÉ", "FINESSE", "PROTECTION"]

var values = [0.0, 0.0, 0.0]    # valeurs affichées en ce moment
var targets = [0.0, 0.0, 0.0]   # valeurs à atteindre (entre 0 et 1)
var color = Color.WHITE


# Donne les nouvelles valeurs à afficher et la couleur des barres
func set_stats(new_targets: Array, new_color: Color):
	targets = new_targets
	color = new_color


# À chaque image : les barres glissent doucement vers leur nouvelle valeur
func _process(delta):
	for i in 3:
		values[i] = lerp(values[i], targets[i], 8 * delta)
	queue_redraw()


# Dessine le nom de chaque statistique et sa barre
func _draw():
	for i in 3:
		var y = i * 30.0
		draw_string(UIStyle.font(), Vector2(0, y + 19), NAMES[i], HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color.WHITE)
		var bar = Rect2(140, y + 6, 240, 14)
		draw_style_box(UIStyle.make_box(Color(1, 1, 1, 0.1), 7), bar)
		if values[i] > 0.02:
			draw_style_box(UIStyle.make_box(color, 7), Rect2(bar.position, Vector2(bar.size.x * values[i], bar.size.y)))
