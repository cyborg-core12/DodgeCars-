extends Obstacle

# Cône de chantier : fait perdre une vie si on le touche

func _ready():
	super()
	kind = "danger"


# Dessin du cône vu du dessus
func _draw():
	draw_circle(Vector2(4, 6), 19, Color(0, 0, 0, 0.25))
	draw_rect(Rect2(-17, -17, 34, 34), Color("c4471a"))
	draw_circle(Vector2.ZERO, 14, Color("ff7b29"))
	draw_circle(Vector2.ZERO, 9, Color.WHITE)
	draw_circle(Vector2.ZERO, 5, Color("ff7b29"))
