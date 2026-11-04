extends Node2D

var enemy_scene = preload("res://scenes/enemy.tscn")
var coin_scene = preload("res://scenes/coin.tscn")

var lanes = [180, 300]
var enemy_speed = 300.0
var spawn_time = 1.6
var goal_distance = 1000.0

var distance = 0.0
var coins = 0
var line_offset = 0.0
var game_over = false
var overlay

func _ready():
	$SpawnTimer.timeout.connect(spawn_enemy)
	$SpawnTimer.wait_time = spawn_time
	$Player.hit.connect(_on_player_hit)
	$Player.coin_collected.connect(_on_coin_collected)
	$Player.set_lanes(lanes)
	$HUD/GameOver/RestartButton.pressed.connect(restart)
	setup_design()
	show_message("Niveau 1\nLa route de campagne")

# ---------- DESIGN ----------

func setup_design():
	
	$HUD/ScoreLabel.position = Vector2(12, 10)
	style_label($HUD/ScoreLabel, 22, Color.WHITE)

	# Barre de progression dorée
	var bar = $HUD/ProgressBar
	bar.position = Vector2(90, 50)
	bar.size = Vector2(300, 16)
	bar.show_percentage = false
	bar.max_value = goal_distance
	bar.add_theme_stylebox_override("background", make_box(Color(0, 0, 0, 0.5)))
	bar.add_theme_stylebox_override("fill", make_box(Color("ffd94a")))

	# Message de début de niveau
	var level_label = $HUD/LevelLabel
	level_label.position = Vector2(0, 330)
	level_label.size = Vector2(480, 100)
	level_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	style_label(level_label, 32, Color("ffd94a"))

	# Fond sombre derrière l'écran de fin
	overlay = ColorRect.new()
	overlay.color = Color(0, 0, 0, 0.6)
	overlay.size = Vector2(480, 800)
	overlay.hide()
	$HUD.add_child(overlay)
	$HUD.move_child(overlay, $HUD/GameOver.get_index())

	# Écran de fin
	var game_over_box = $HUD/GameOver
	game_over_box.hide()
	game_over_box.position = Vector2(60, 250)
	game_over_box.size = Vector2(360, 300)
	game_over_box.alignment = BoxContainer.ALIGNMENT_CENTER
	game_over_box.add_theme_constant_override("separation", 25)

	var final_label = $HUD/GameOver/FinalLabel
	final_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	style_label(final_label, 40, Color.WHITE)

	# Bouton orange arrondi
	var button = $HUD/GameOver/RestartButton
	button.text = "Rejouer (Entrée)"
	button.add_theme_font_size_override("font_size", 26)
	button.add_theme_stylebox_override("normal", make_box(Color("e8641b")))
	button.add_theme_stylebox_override("hover", make_box(Color("ff8a3d")))
	button.add_theme_stylebox_override("pressed", make_box(Color("b84a10")))
	button.add_theme_stylebox_override("focus", StyleBoxEmpty.new())

func style_label(label, font_size, color):
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_outline_color", Color.BLACK)
	label.add_theme_constant_override("outline_size", 8)

func make_box(color):
	var box = StyleBoxFlat.new()
	box.bg_color = color
	box.set_corner_radius_all(12)
	box.set_content_margin_all(12)
	return box

# ---------- JEU ----------

func _process(delta):
	if game_over:
		if Input.is_action_just_pressed("ui_accept"):
			restart()
		return

	# Distance parcourue
	distance += enemy_speed * delta / 10
	$HUD/ScoreLabel.text = "Distance : %d m     Pièces : %d" % [distance, coins]
	$HUD/ProgressBar.value = distance

	# Niveau réussi
	if distance >= goal_distance:
		end_game("Niveau 1 réussi !\nPièces : %d" % coins)
		return

	# Fait défiler les lignes blanches
	line_offset += enemy_speed * delta
	if line_offset >= 80:
		line_offset -= 80
	queue_redraw()

func spawn_enemy():
	var enemy_lane = lanes.pick_random()
	var enemy = enemy_scene.instantiate()
	enemy.position = Vector2(enemy_lane, -100)
	enemy.speed = enemy_speed
	add_child(enemy)

	# Une chance sur deux de mettre une pièce dans une voie libre
	if randf() < 0.5:
		var free_lanes = lanes.duplicate()
		free_lanes.erase(enemy_lane)
		var coin = coin_scene.instantiate()
		coin.position = Vector2(free_lanes.pick_random(), -100)
		coin.speed = enemy_speed
		add_child(coin)

func _on_coin_collected():
	coins += 1

func show_message(text):
	$HUD/LevelLabel.text = text
	$HUD/LevelLabel.show()
	await get_tree().create_timer(2.5).timeout
	$HUD/LevelLabel.hide()

func _on_player_hit():
	if game_over:
		return
	end_game("Game Over\n%d m\nPièces : %d" % [distance, coins])

func end_game(text):
	game_over = true
	$SpawnTimer.stop()
	$Player.set_process(false)
	get_tree().call_group("enemies", "set_process", false)
	get_tree().call_group("coins", "set_process", false)
	$HUD/ScoreLabel.hide()
	$HUD/ProgressBar.hide()
	$HUD/LevelLabel.hide()
	overlay.show()
	$HUD/GameOver/FinalLabel.text = text
	$HUD/GameOver.show()

func restart():
	get_tree().reload_current_scene()

func _draw():
	# Herbe
	draw_rect(Rect2(0, 0, 480, 800), Color("3a7d44"))
	# Route (s'adapte au nombre de voies)
	var left = lanes[0] - 60
	var right = lanes[-1] + 60
	draw_rect(Rect2(left, 0, right - left, 800), Color("555555"))
	# Bordures blanches sur les côtés de la route
	draw_rect(Rect2(left, 0, 6, 800), Color.WHITE)
	draw_rect(Rect2(right - 6, 0, 6, 800), Color.WHITE)
	# Lignes blanches entre les voies
	for i in range(lanes.size() - 1):
		var x = (lanes[i] + lanes[i + 1]) / 2.0
		var y = -80 + line_offset
		while y < 800:
			draw_rect(Rect2(x - 3, y, 6, 40), Color.WHITE)
			y += 80
