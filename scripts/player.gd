extends Area2D

signal hit
signal coin_collected

# Position horizontale des 3 voies
var lanes = [120, 240, 360]
var current_lane = 1
var move_speed = 10.0

func _ready():
	position = Vector2(lanes[current_lane], 700)
	area_entered.connect(_on_area_entered)

func _process(delta):
	if Input.is_action_just_pressed("ui_left") and current_lane > 0:
		current_lane -= 1
	if Input.is_action_just_pressed("ui_right") and current_lane < lanes.size() - 1:
		current_lane += 1
	position.x = lerp(position.x, float(lanes[current_lane]), move_speed * delta)

func _on_area_entered(area):
	if area.is_in_group("enemies"):
		hit.emit()
	elif area.is_in_group("coins"):
		coin_collected.emit()
		area.queue_free()
		
func set_lanes(new_lanes):
	lanes = new_lanes
	current_lane = min(current_lane, lanes.size() - 1)
