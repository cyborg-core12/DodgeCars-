extends Obstacle

## Flaque d'huile : ne fait pas perdre de vie,
## mais inverse les contrôles du joueur pendant quelques secondes.


func _ready():
	super()
	kind = "oil"


func _draw():
	var oil = Color(0.05, 0.05, 0.08, 0.9)
	draw_circle(Vector2(0, 0), 24, oil)
	draw_circle(Vector2(-18, 8), 14, oil)
	draw_circle(Vector2(16, -10), 16, oil)
	draw_circle(Vector2(10, 16), 12, oil)
	# Reflets colorés de l'huile
	draw_arc(Vector2(-4, -4), 12, PI, PI * 1.6, 12, Color(0.7, 0.4, 1, 0.7), 3)
	draw_arc(Vector2(10, 4), 8, 0, PI * 0.7, 10, Color(0.3, 0.9, 1, 0.6), 2)
