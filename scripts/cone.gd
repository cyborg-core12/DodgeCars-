extends Obstacle

## Cône de chantier (vu du dessus). Le toucher fait perdre une vie.


func _ready():
	super()
	kind = "danger"


func _draw():
	draw_circle(Vector2(4, 6), 19, Color(0, 0, 0, 0.25))   # ombre
	draw_rect(Rect2(-17, -17, 34, 34), Color("c4471a"))     # socle carré
	draw_circle(Vector2.ZERO, 14, Color("ff7b29"))         # cône
	draw_circle(Vector2.ZERO, 9, Color.WHITE)              # bande blanche
	draw_circle(Vector2.ZERO, 5, Color("ff7b29"))          # pointe
