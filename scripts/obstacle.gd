class_name Obstacle
extends Area2D

# Classe de base de tout ce qui descend la route

# Vitesse commune à tous les obstacles
static var world_speed = 320.0

var kind = "danger"

var speed_factor = 1.0


func _ready():
	add_to_group("obstacles")


func _process(delta):
	position.y += world_speed * speed_factor * delta
	if position.y > 1000:
		queue_free()
