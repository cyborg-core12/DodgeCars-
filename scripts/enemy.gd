extends Area2D

var speed = 300.0

var textures = [
	preload("res://assets/car_black_4.png"),
	preload("res://assets/car_green_1.png"),
	preload("res://assets/car_yellow_4.png"),
]

func _ready():
	add_to_group("enemies")
	
	$Sprite2D.texture = textures.pick_random()
	
	$VisibleOnScreenNotifier2D.screen_exited.connect(queue_free)

func _process(delta):
	position.y += speed * delta
