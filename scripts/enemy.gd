extends Obstacle

# Voiture ennemie (certaines changent de voie)

var textures = [
	preload("res://assets/car_black_4.png"),
	preload("res://assets/car_green_1.png"),
	preload("res://assets/car_yellow_4.png"),
]

var lane_changer = false
var lanes = []
var target_lane = 0
var target_x = 0.0
var direction = 0
var has_changed = false
var time = 0.0


func _ready():
	super()
	kind = "danger"
	$Sprite2D.texture = textures.pick_random()
	target_x = position.x


# Appelée par main.gd pour que la voiture change de voie
func make_lane_changer(lane_list: Array, current_lane: int):
	lanes = lane_list
	lane_changer = true
	if current_lane == 0:
		direction = 1
	elif current_lane == lanes.size() - 1:
		direction = -1
	else:
		direction = [-1, 1].pick_random()
	target_lane = current_lane + direction


func _process(delta):
	super(delta)
	time += delta

	if lane_changer and not has_changed and position.y > 140:
		has_changed = true
		target_x = lanes[target_lane]

	position.x = move_toward(position.x, target_x, world_speed * 0.45 * delta)
	rotation = clamp(-(target_x - position.x) * 0.004, -0.3, 0.3)
	queue_redraw()


# Ombre et clignotant
func _draw():
	draw_rect(Rect2(-35 + 6, -65 + 8, 71, 131), Color(0, 0, 0, 0.3))

	var turning = not has_changed or abs(target_x - position.x) > 2
	if lane_changer and turning:
		if fmod(time, 0.4) < 0.2:
			var side = direction * 40
			for y in [-50, 50]:
				draw_circle(Vector2(side, y), 11, Color(1, 0.6, 0, 0.35))
				draw_circle(Vector2(side, y), 6, Color("ffb703"))
