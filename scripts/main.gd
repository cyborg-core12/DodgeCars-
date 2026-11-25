extends Node2D

## Scène principale : fait apparaître les obstacles, gère la difficulté,
## les zones, le score, les combos et la fin de partie.

const LANES = [130, 240, 350]
const START_SPEED = 320.0
const MAX_SPEED = 780.0
const DISTANCE_MAX_DIFFICULTY = 3500.0   # mètres pour atteindre la difficulté maximale
const ZONE_LENGTH = 600.0                # mètres entre deux zones

var car_scene = preload("res://scenes/enemy.tscn")
var cone_scene = preload("res://scenes/cone.tscn")
var oil_scene = preload("res://scenes/oil.tscn")
var pickup_scene = preload("res://scenes/pickup.tscn")

var speed = START_SPEED
var distance = 0.0
var coins = 0
var bonus_points = 0
var combo = 0
var combo_timer = 0.0
var zone_index = 0
var spawn_cooldown = 1.5
var shake = 0.0
var game_over = false

@onready var road = $Road
@onready var world = $World
@onready var player = $Player
@onready var effects = $Effects
@onready var hud = $HUD
@onready var camera = $Camera2D
@onready var engine_sound = $EngineSound


func _ready():
	get_tree().paused = false
	Obstacle.world_speed = START_SPEED
	player.set_lanes(LANES)
	player.crashed.connect(_on_player_crashed)
	player.died.connect(_on_player_died)
	player.shield_broken.connect(_on_shield_broken)
	player.coin_collected.connect(_on_coin_collected)
	player.powerup_collected.connect(_on_powerup_collected)
	player.slipped.connect(_on_player_slipped)
	hud.restart_requested.connect(restart)
	hud.menu_requested.connect(go_to_menu)
	engine_sound.finished.connect(engine_sound.play)   # le son du moteur tourne en boucle
	engine_sound.play()
	_enter_zone(0)


# 0.0 au début, 1.0 quand le jeu est au maximum de difficulté
func difficulty() -> float:
	return clamp(distance / DISTANCE_MAX_DIFFICULTY, 0.0, 1.0)


func get_score() -> int:
	return int(distance) + bonus_points


func _process(delta):
	_update_shake(delta)
	if game_over:
		road.speed = move_toward(road.speed, 0.0, 500 * delta)   # la route freine
		return

	# Plus on avance, plus ça va vite
	speed = lerp(START_SPEED, MAX_SPEED, difficulty())
	Obstacle.world_speed = speed
	road.speed = speed
	distance += speed * delta / 10.0
	engine_sound.pitch_scale = 0.9 + difficulty() * 0.5

	# ... et plus les obstacles arrivent souvent
	spawn_cooldown -= delta
	if spawn_cooldown <= 0:
		spawn_pattern()
		spawn_cooldown = lerp(1.3, 0.6, difficulty())

	combo_timer -= delta
	if combo_timer <= 0:
		combo = 0

	var new_zone = int(distance / ZONE_LENGTH)
	if new_zone != zone_index:
		_enter_zone(new_zone)

	hud.update_stats(get_score(), GameData.best_score, coins, player.lives,
		fmod(distance, ZONE_LENGTH) / ZONE_LENGTH,
		player.shield_time, player.magnet_time, player.slip_time)


# ---------- ZONES ----------

func _enter_zone(index: int):
	zone_index = index
	var zone_number = index % Road.ZONES.size()
	var zone = Road.ZONES[zone_number]
	road.set_zone(zone_number)
	player.night = zone.get("night", false)
	var tween = create_tween()
	tween.tween_property($Tint, "color", zone.tint, 2.0)
	hud.set_zone(index + 1, zone.name)
	if index == 0:
		hud.show_message("C'EST PARTI !\n" + zone.name)
	else:
		bonus_points += 100
		hud.show_message("ZONE %d\n%s" % [index + 1, zone.name])
		spawn_float_text(player.position + Vector2(0, -110), "+100", UIStyle.GREEN)


# ---------- APPARITION DES OBSTACLES ----------

# Choisit un "motif" d'obstacles. Il reste toujours au moins une voie libre.
func spawn_pattern():
	var d = difficulty()
	var free_lanes = [0, 1, 2]
	var roll = randf()

	if d > 0.25 and roll < 0.18:
		# Voiture qui change de voie (avec clignotant)
		var lane = randi() % 3
		var car = spawn_car(lane)
		car.make_lane_changer(LANES, lane)
		free_lanes.clear()
	elif d > 0.1 and roll < 0.42:
		# Deux voitures côte à côte : une seule voie libre !
		var order = [0, 1, 2]
		order.shuffle()
		spawn_car(order[0])
		spawn_car(order[1])
		free_lanes = [order[2]]
	elif roll < 0.58:
		# Rangée de cônes de chantier
		var lane = randi() % 3
		for i in 3:
			spawn_object(cone_scene, lane, -60 - i * 75)
		free_lanes.erase(lane)
	elif roll < 0.72:
		# Flaque d'huile, parfois avec une voiture à côté
		var lane = randi() % 3
		spawn_object(oil_scene, lane, -80)
		free_lanes.erase(lane)
		if d > 0.2:
			var other = free_lanes.pick_random()
			spawn_car(other)
			free_lanes.erase(other)
	else:
		# Une seule voiture, un peu plus lente
		var lane = randi() % 3
		var car = spawn_car(lane)
		car.speed_factor = randf_range(0.8, 1.0)
		free_lanes.erase(lane)

	# Des pièces ou un bonus dans une voie libre
	if free_lanes.is_empty():
		return
	var lane = free_lanes.pick_random()
	var r = randf()
	if r < 0.05:
		spawn_pickup("shield", lane, -100)
	elif r < 0.10:
		spawn_pickup("magnet", lane, -100)
	elif r < 0.13 and player.lives < player.MAX_LIVES:
		spawn_pickup("heart", lane, -100)
	elif r < 0.6:
		for i in randi_range(3, 5):
			spawn_pickup("coin", lane, -100 - i * 60)


func spawn_object(scene: PackedScene, lane: int, y := -100.0) -> Node2D:
	var obj = scene.instantiate()
	obj.position = Vector2(LANES[lane], y)
	world.add_child(obj)
	return obj


func spawn_car(lane: int, y := -100.0) -> Node2D:
	return spawn_object(car_scene, lane, y)


func spawn_pickup(kind: String, lane: int, y: float):
	var item = pickup_scene.instantiate()
	item.kind = kind
	item.position = Vector2(LANES[lane], y)
	world.add_child(item)


# ---------- ÉVÉNEMENTS DU JOUEUR ----------

func _on_coin_collected(pos: Vector2):
	coins += 1
	# Pièces ramassées à la suite = combo (jusqu'à x5)
	combo = min(combo + 1, 5) if combo_timer > 0 else 1
	combo_timer = 1.6
	var points = 10 * combo
	bonus_points += points
	spawn_burst(pos, UIStyle.YELLOW, 12, 180.0, 4.0)
	spawn_float_text(pos, "+%d" % points, UIStyle.YELLOW)
	if combo >= 2:
		hud.show_combo(combo)


func _on_powerup_collected(kind: String, pos: Vector2):
	var texts = {"shield": "BOUCLIER !", "magnet": "AIMANT !", "heart": "+1 VIE"}
	var colors = {"shield": UIStyle.BLUE, "magnet": UIStyle.RED, "heart": UIStyle.GREEN}
	spawn_burst(pos, colors[kind], 30, 260.0, 6.0)
	spawn_float_text(pos, texts[kind], colors[kind])


func _on_player_slipped():
	shake = 6
	spawn_float_text(player.position + Vector2(0, -90), "GLISSADE !", UIStyle.PURPLE)


func _on_shield_broken(obstacle):
	_destroy(obstacle)
	shake = 8
	spawn_burst(player.position, UIStyle.BLUE, 30, 300.0, 6.0)
	spawn_float_text(player.position + Vector2(0, -90), "PROTÉGÉ !", UIStyle.BLUE)


func _on_player_crashed(obstacle):
	_destroy(obstacle)
	combo = 0
	shake = 14
	hud.flash_screen(UIStyle.RED)
	spawn_float_text(player.position + Vector2(0, -90), "-1 VIE", UIStyle.RED)


func _on_player_died(obstacle):
	game_over = true
	_destroy(obstacle)
	spawn_explosion(player.global_position)
	shake = 22
	hud.flash_screen(UIStyle.RED)
	engine_sound.stop()
	world.process_mode = Node.PROCESS_MODE_DISABLED   # tout s'arrête

	# La voiture du joueur part en tête-à-queue
	var tween = create_tween().set_parallel(true)
	tween.tween_property(player, "rotation", player.rotation + 2.5, 0.8) \
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(player, "modulate", Color(0.35, 0.35, 0.35), 0.8)

	var score = get_score()
	var is_record = GameData.submit_score(score, coins)
	hud.playing = false
	hud.update_stats(score, GameData.best_score, coins, 0, 0.0, 0.0, 0.0, 0.0)
	await get_tree().create_timer(1.1).timeout
	hud.show_game_over(score, int(distance), coins, GameData.best_score, is_record)


# ---------- EFFETS VISUELS ----------

func _destroy(obstacle):
	spawn_explosion(obstacle.global_position)
	obstacle.queue_free()


func spawn_explosion(pos: Vector2):
	spawn_burst(pos, Color("ff9f1c"), 40, 380.0, 9.0)
	spawn_burst(pos, UIStyle.YELLOW, 20, 250.0, 6.0)
	spawn_burst(pos, Color(0.4, 0.4, 0.45), 16, 150.0, 14.0)


# Petite explosion de particules
func spawn_burst(pos: Vector2, color: Color, amount: int, power: float, particle_size: float):
	var particles = CPUParticles2D.new()
	particles.position = pos
	particles.one_shot = true
	particles.explosiveness = 0.95
	particles.amount = amount
	particles.lifetime = 0.7
	particles.spread = 180
	particles.direction = Vector2.UP
	particles.gravity = Vector2(0, 300)
	particles.initial_velocity_min = power * 0.4
	particles.initial_velocity_max = power
	particles.damping_min = 80
	particles.damping_max = 160
	particles.scale_amount_min = particle_size * 0.5
	particles.scale_amount_max = particle_size
	var gradient = Gradient.new()
	gradient.colors = PackedColorArray([color, Color(color, 0.0)])
	particles.color_ramp = gradient
	effects.add_child(particles)
	particles.emitting = true
	get_tree().create_timer(1.2).timeout.connect(particles.queue_free)


# Texte qui monte et disparaît (+10, -1 VIE...)
func spawn_float_text(pos: Vector2, text: String, color: Color):
	var label = UIStyle.make_label(text, 26, color, pos - Vector2(100, 20), Vector2(200, 40))
	effects.add_child(label)
	var tween = label.create_tween().set_parallel(true)
	tween.tween_property(label, "position:y", label.position.y - 70, 0.8) \
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(label, "modulate:a", 0.0, 0.5).set_delay(0.3)
	tween.chain().tween_callback(label.queue_free)


# Tremblement de l'écran
func _update_shake(delta):
	shake = move_toward(shake, 0.0, 40 * delta)
	camera.offset = Vector2(randf_range(-shake, shake), randf_range(-shake, shake))


# ---------- NAVIGATION ----------

func restart():
	get_tree().paused = false
	get_tree().reload_current_scene()


func go_to_menu():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/menu.tscn")
