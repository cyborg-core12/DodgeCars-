extends Area2D

# Voiture du joueur

signal crashed(obstacle)
signal died(obstacle)
signal shield_broken(obstacle)
signal coin_collected(coin_position)
signal powerup_collected(kind, item_position)
signal slipped

const INVINCIBLE_DURATION = 1.5
const SHIELD_DURATION = 8.0
const MAGNET_DURATION = 8.0
const SLIP_DURATION = 2.5

var lanes = [130, 240, 350]
var current_lane = 1
var move_speed = 12.0
var max_lives = 3
var lives = 3
var alive = true
var night = false

var invincible_time = 0.0
var shield_time = 0.0
var magnet_time = 0.0
var slip_time = 0.0
var time = 0.0

@onready var fx = $FX

const CAR_HEIGHT = 135.0
var car_size = Vector2(71, 131)


func _ready():
	add_to_group("player")
	position = Vector2(lanes[current_lane], 670)
	area_entered.connect(_on_area_entered)
	fx.draw.connect(_draw_fx)
	apply_car(GameData.car_settings())


# Applique la voiture choisie au garage
func apply_car(settings: Dictionary):
	var texture = load(settings.texture)
	$Sprite2D.texture = texture
	var s = CAR_HEIGHT / texture.get_height()
	$Sprite2D.scale = Vector2(s, s)
	car_size = texture.get_size() * s

	var shape = RectangleShape2D.new()
	shape.size = car_size * Vector2(0.8, 0.86)
	$CollisionShape2D.shape = shape
	$CollisionShape2D.position = Vector2.ZERO

	$Exhaust.position = Vector2(-car_size.x * 0.22, car_size.y / 2 - 2)

	move_speed = settings.handling
	shield_time = settings.shield


func set_lanes(new_lanes):
	lanes = new_lanes
	current_lane = clamp(current_lane, 0, lanes.size() - 1)
	position.x = lanes[current_lane]


func _unhandled_input(event):
	if not alive:
		return
	var dir = 0
	if event.is_action_pressed("ui_left") or _is_key(event, KEY_A):
		dir = -1
	elif event.is_action_pressed("ui_right") or _is_key(event, KEY_D):
		dir = 1
	if dir == 0:
		return
	if slip_time > 0:
		dir = -dir
	current_lane = clamp(current_lane + dir, 0, lanes.size() - 1)


func _is_key(event, key) -> bool:
	return event is InputEventKey and event.pressed and not event.echo and event.physical_keycode == key


func _process(delta):
	time += delta
	invincible_time = max(invincible_time - delta, 0.0)
	shield_time = max(shield_time - delta, 0.0)
	magnet_time = max(magnet_time - delta, 0.0)
	slip_time = max(slip_time - delta, 0.0)
	queue_redraw()
	fx.queue_redraw()

	if not alive:
		return

	var target_x = float(lanes[current_lane])
	position.x = lerp(position.x, target_x, move_speed * delta)

	var tilt = clamp((target_x - position.x) * 0.006, -0.35, 0.35)
	if slip_time > 0:
		tilt += sin(time * 18.0) * 0.12
	rotation = lerp(rotation, tilt, 15 * delta)

	if invincible_time > 0 and fmod(time, 0.16) < 0.08:
		$Sprite2D.modulate.a = 0.3
	else:
		$Sprite2D.modulate.a = 1.0


func _on_area_entered(area):
	if not alive or not (area is Obstacle):
		return
	match area.kind:
		"danger":
			_on_danger(area)
		"oil":
			if slip_time <= 0 and invincible_time <= 0:
				slip_time = SLIP_DURATION
				slipped.emit()
		"coin":
			coin_collected.emit(area.global_position)
			area.queue_free()
		"shield":
			shield_time = SHIELD_DURATION
			_collect(area)
		"magnet":
			magnet_time = MAGNET_DURATION
			_collect(area)
		"heart":
			lives = min(lives + 1, max_lives)
			_collect(area)


func _collect(area):
	powerup_collected.emit(area.kind, area.global_position)
	area.queue_free()


# Collision avec un obstacle : bouclier, invincibilité ou perte d'une vie
func _on_danger(obstacle):
	if shield_time > 0:
		shield_time = 0.0
		invincible_time = 0.5
		shield_broken.emit(obstacle)
		return
	if invincible_time > 0:
		return
	lives -= 1
	if lives <= 0:
		alive = false
		died.emit(obstacle)
	else:
		invincible_time = INVINCIBLE_DURATION
		crashed.emit(obstacle)


func _draw():
	draw_rect(Rect2(-car_size / 2 + Vector2(6, 8), car_size), Color(0, 0, 0, 0.3))
	if night and alive:
		var beam = Color(1, 0.95, 0.6, 0.22)
		var front = -car_size.y / 2 + 4
		for side in [-20, 20]:
			draw_colored_polygon(PackedVector2Array([
				Vector2(side - 6, front), Vector2(side + 6, front),
				Vector2(side + 30, front - 258), Vector2(side - 30, front - 258),
			]), beam)


func _draw_fx():
	if shield_time > 0:
		var alpha = 0.25 if shield_time > 2.0 or fmod(time, 0.3) < 0.15 else 0.08
		fx.draw_circle(Vector2.ZERO, 82, Color(0.3, 0.8, 1, alpha))
		fx.draw_arc(Vector2.ZERO, 82, 0, TAU, 48, Color(0.6, 0.95, 1, 0.9), 3)
	if magnet_time > 0:
		for i in 6:
			var angle = time * 3.0 + i * TAU / 6.0
			fx.draw_circle(Vector2(cos(angle), sin(angle)) * 95, 5, Color(1, 0.3, 0.4, 0.85))
