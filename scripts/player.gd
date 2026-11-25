extends Area2D

## Voiture du joueur : changement de voie, vies, bonus et effets visuels.

signal crashed(obstacle)          # a perdu une vie
signal died(obstacle)             # n'a plus de vie
signal shield_broken(obstacle)    # le bouclier a encaissé le choc
signal coin_collected(coin_position)
signal powerup_collected(kind, item_position)
signal slipped                    # a roulé dans l'huile

const INVINCIBLE_DURATION = 1.5
const SHIELD_DURATION = 8.0
const MAGNET_DURATION = 8.0
const SLIP_DURATION = 2.5

var lanes = [130, 240, 350]
var current_lane = 1
var move_speed = 12.0
var max_lives = 3   # dépend du niveau (main.gd le change)
var lives = 3
var alive = true
var night = false   # phares allumés la nuit

# Minuteurs (en secondes) des différents effets
var invincible_time = 0.0
var shield_time = 0.0
var magnet_time = 0.0
var slip_time = 0.0
var time = 0.0

var fx: Node2D   # calque dessiné PAR-DESSUS la voiture (bouclier, aimant)


func _ready():
	add_to_group("player")
	position = Vector2(lanes[current_lane], 670)
	area_entered.connect(_on_area_entered)

	fx = Node2D.new()
	add_child(fx)
	fx.draw.connect(_draw_fx)
	_create_exhaust()


func set_lanes(new_lanes):
	lanes = new_lanes
	current_lane = clamp(current_lane, 0, lanes.size() - 1)
	position.x = lanes[current_lane]


# ---------- CONTRÔLES ----------

func _unhandled_input(event):
	if not alive:
		return
	var dir = 0
	# Flèches, ou Q / D sur un clavier AZERTY (touches physiques A / D en QWERTY)
	if event.is_action_pressed("ui_left") or _is_key(event, KEY_A):
		dir = -1
	elif event.is_action_pressed("ui_right") or _is_key(event, KEY_D):
		dir = 1
	if dir == 0:
		return
	# Dans l'huile, les contrôles sont inversés !
	if slip_time > 0:
		dir = -dir
	current_lane = clamp(current_lane + dir, 0, lanes.size() - 1)


func _is_key(event, key) -> bool:
	return event is InputEventKey and event.pressed and not event.echo and event.physical_keycode == key


# ---------- MOUVEMENT ----------

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

	# La voiture penche dans les virages, et dérape dans l'huile
	var tilt = clamp((target_x - position.x) * 0.006, -0.35, 0.35)
	if slip_time > 0:
		tilt += sin(time * 18.0) * 0.12
	rotation = lerp(rotation, tilt, 15 * delta)

	# Clignote quand elle est invincible après un choc
	if invincible_time > 0 and fmod(time, 0.16) < 0.08:
		$Sprite2D.modulate.a = 0.3
	else:
		$Sprite2D.modulate.a = 1.0


# ---------- COLLISIONS ----------

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


func _on_danger(obstacle):
	# Le bouclier encaisse le choc à notre place
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


# ---------- DESSIN ----------

func _draw():
	# Ombre
	draw_rect(Rect2(-35 + 6, -65 + 8, 71, 131), Color(0, 0, 0, 0.3))
	# Phares la nuit
	if night and alive:
		var beam = Color(1, 0.95, 0.6, 0.22)
		for side in [-20, 20]:
			draw_colored_polygon(PackedVector2Array([
				Vector2(side - 6, -62), Vector2(side + 6, -62),
				Vector2(side + 30, -320), Vector2(side - 30, -320),
			]), beam)


func _draw_fx():
	if shield_time > 0:
		# Le bouclier clignote quand il va bientôt disparaître
		var alpha = 0.25 if shield_time > 2.0 or fmod(time, 0.3) < 0.15 else 0.08
		fx.draw_circle(Vector2.ZERO, 82, Color(0.3, 0.8, 1, alpha))
		fx.draw_arc(Vector2.ZERO, 82, 0, TAU, 48, Color(0.6, 0.95, 1, 0.9), 3)
	if magnet_time > 0:
		for i in 6:
			var angle = time * 3.0 + i * TAU / 6.0
			fx.draw_circle(Vector2(cos(angle), sin(angle)) * 95, 5, Color(1, 0.3, 0.4, 0.85))


# Fumée du pot d'échappement (particules)
func _create_exhaust():
	var smoke = CPUParticles2D.new()
	smoke.position = Vector2(-16, 64)
	smoke.amount = 24
	smoke.lifetime = 0.5
	smoke.local_coords = false
	smoke.direction = Vector2(0, 1)
	smoke.spread = 15
	smoke.gravity = Vector2.ZERO
	smoke.initial_velocity_min = 180
	smoke.initial_velocity_max = 260
	smoke.scale_amount_min = 3
	smoke.scale_amount_max = 6
	var gradient = Gradient.new()
	gradient.colors = PackedColorArray([Color(0.85, 0.85, 0.9, 0.5), Color(0.85, 0.85, 0.9, 0)])
	smoke.color_ramp = gradient
	smoke.show_behind_parent = true
	add_child(smoke)
