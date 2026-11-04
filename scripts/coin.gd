extends Area2D

var speed = 300.0

func _ready():
	add_to_group("coins")

func _process(delta):
	position.y += speed * delta
	# Supprime la pièce quand elle sort de l'écran
	if position.y > 900:
		queue_free()

func _draw():
	# Dessine une pièce dorée
	draw_circle(Vector2.ZERO, 15, Color("d4a017"))
	draw_circle(Vector2.ZERO, 11, Color("ffd94a"))
