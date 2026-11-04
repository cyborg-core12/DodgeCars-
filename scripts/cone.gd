extends Area2D
 
var speed = 300.0
 
func _ready():

	# Même groupe que les voitures : le toucher fait perdre

	add_to_group("enemies")
 
func _process(delta):

	position.y += speed * delta

	if position.y > 900:

		queue_free()
 
func _draw():

	# Cône de chantier vu du dessus

	draw_rect(Rect2(-16, -16, 32, 32), Color("b84a10"))

	draw_circle(Vector2.ZERO, 13, Color("ff7a1a"))

	draw_circle(Vector2.ZERO, 9, Color.WHITE)

	draw_circle(Vector2.ZERO, 5, Color("ff7a1a"))
 
