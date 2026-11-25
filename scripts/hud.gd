extends CanvasLayer

## Interface du jeu : score, vies, pièces, bonus actifs, messages,
## menu pause et écran de fin. Tous les éléments sont créés par le code.

signal restart_requested
signal menu_requested

var playing = true
var lives = 3
var shield_time = 0.0
var magnet_time = 0.0
var time = 0.0

var score_label: Label
var best_label: Label
var coins_label: Label
var zone_label: Label
var zone_bar: Panel   # partie jaune de la barre de progression
var hearts: Control
var powerups: Control
var message_label: Label
var combo_label: Label
var warning_label: Label
var hint_label: Label
var flash: ColorRect

var pause_menu: Control
var resume_button: Button
var game_over_menu: Control
var record_label: Label
var final_score: Label
var final_stats: Label
var restart_button: Button

var message_tween: Tween
var combo_tween: Tween


func _ready():
	# Le HUD continue de fonctionner quand le jeu est en pause
	process_mode = Node.PROCESS_MODE_ALWAYS
	_build_top_bar()
	_build_messages()
	pause_menu = _build_pause_menu()
	game_over_menu = _build_game_over()


func _process(delta):
	time += delta
	if record_label.visible:
		record_label.modulate.a = 0.6 + 0.4 * sin(time * 8.0)
	if warning_label.visible:
		warning_label.modulate.a = 0.5 + 0.5 * sin(time * 12.0)


# ---------- CONSTRUCTION ----------

func _build_top_bar():
	var bar = UIStyle.make_panel(Vector2(10, 10), Vector2(460, 74))
	add_child(bar)

	hearts = Control.new()
	hearts.position = Vector2(14, 16)
	hearts.size = Vector2(120, 42)
	hearts.draw.connect(_draw_hearts)
	bar.add_child(hearts)

	score_label = UIStyle.make_label("0", 34, Color.WHITE, Vector2(130, 2), Vector2(200, 44))
	bar.add_child(score_label)
	best_label = UIStyle.make_label("RECORD 0", 14, UIStyle.YELLOW, Vector2(130, 44), Vector2(200, 22))
	best_label.add_theme_constant_override("outline_size", 4)
	bar.add_child(best_label)

	var coin_icon = Control.new()
	coin_icon.position = Vector2(350, 22)
	coin_icon.size = Vector2(30, 30)
	coin_icon.draw.connect(func(): UIStyle.draw_coin(coin_icon, Vector2(15, 15), 13))
	bar.add_child(coin_icon)
	coins_label = UIStyle.make_label("0", 26, UIStyle.YELLOW, Vector2(386, 14), Vector2(64, 46), HORIZONTAL_ALIGNMENT_LEFT)
	bar.add_child(coins_label)

	# Barre de progression jusqu'à la prochaine zone
	var bar_background = Panel.new()
	bar_background.position = Vector2(20, 92)
	bar_background.size = Vector2(440, 10)
	bar_background.add_theme_stylebox_override("panel", UIStyle.make_box(Color(0, 0, 0, 0.45), 5, 0))
	add_child(bar_background)
	zone_bar = Panel.new()
	zone_bar.size = Vector2(0, 10)
	zone_bar.add_theme_stylebox_override("panel", UIStyle.make_box(UIStyle.YELLOW, 5, 0))
	bar_background.add_child(zone_bar)

	zone_label = UIStyle.make_label("", 14, Color.WHITE, Vector2(20, 104), Vector2(440, 22))
	zone_label.add_theme_constant_override("outline_size", 5)
	add_child(zone_label)

	powerups = Control.new()
	powerups.position = Vector2(14, 700)
	powerups.size = Vector2(300, 90)
	powerups.draw.connect(_draw_powerups)
	add_child(powerups)


func _build_messages():
	message_label = UIStyle.make_label("", 42, UIStyle.YELLOW, Vector2(0, 290), Vector2(480, 160))
	message_label.pivot_offset = Vector2(240, 80)
	message_label.hide()
	add_child(message_label)

	combo_label = UIStyle.make_label("", 30, UIStyle.ORANGE, Vector2(0, 140), Vector2(480, 50))
	combo_label.pivot_offset = Vector2(240, 25)
	combo_label.modulate.a = 0
	add_child(combo_label)

	warning_label = UIStyle.make_label("CONTRÔLES INVERSÉS !", 24, UIStyle.PURPLE, Vector2(0, 540), Vector2(480, 40))
	warning_label.hide()
	add_child(warning_label)

	hint_label = UIStyle.make_label("← →  ou  Q D : changer de voie\nP / Échap : pause", 16, Color.WHITE, Vector2(0, 600), Vector2(480, 60))
	hint_label.add_theme_constant_override("outline_size", 4)
	add_child(hint_label)
	var tween = create_tween()
	tween.tween_interval(5.0)
	tween.tween_property(hint_label, "modulate:a", 0.0, 1.0)

	# Flash rouge quand on se fait toucher
	flash = ColorRect.new()
	flash.size = Vector2(480, 800)
	flash.color = Color(1, 0, 0, 0)
	flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(flash)


func _make_overlay() -> Control:
	var overlay = Control.new()
	overlay.size = Vector2(480, 800)
	var dark = ColorRect.new()
	dark.size = Vector2(480, 800)
	dark.color = Color(0, 0, 0, 0.65)
	overlay.add_child(dark)
	overlay.hide()
	add_child(overlay)
	return overlay


func _make_menu_box(card: Panel, box_size: Vector2) -> VBoxContainer:
	var box = VBoxContainer.new()
	box.position = Vector2(30, 24)
	box.size = box_size
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 14)
	card.add_child(box)
	return box


func _box_label(box: VBoxContainer, text: String, font_size: int, color: Color, height: float) -> Label:
	var label = UIStyle.make_label(text, font_size, color, Vector2.ZERO, Vector2.ZERO)
	label.custom_minimum_size = Vector2(0, height)
	box.add_child(label)
	return label


func _build_pause_menu() -> Control:
	var overlay = _make_overlay()
	var card = UIStyle.make_panel(Vector2(60, 240), Vector2(360, 320))
	overlay.add_child(card)
	var box = _make_menu_box(card, Vector2(300, 272))
	_box_label(box, "PAUSE", 48, Color.WHITE, 80)

	resume_button = Button.new()
	UIStyle.style_button(resume_button, "Reprendre", UIStyle.GREEN)
	resume_button.pressed.connect(toggle_pause)
	box.add_child(resume_button)

	var menu_button = Button.new()
	UIStyle.style_button(menu_button, "Menu principal", UIStyle.GREY, 22)
	menu_button.pressed.connect(_go_menu)
	box.add_child(menu_button)
	return overlay


func _build_game_over() -> Control:
	var overlay = _make_overlay()
	var card = UIStyle.make_panel(Vector2(30, 120), Vector2(420, 560))
	overlay.add_child(card)
	var box = _make_menu_box(card, Vector2(360, 512))
	_box_label(box, "GAME OVER", 52, UIStyle.RED, 70)
	record_label = _box_label(box, "NOUVEAU RECORD !", 24, UIStyle.YELLOW, 34)
	final_score = _box_label(box, "0", 64, Color.WHITE, 80)
	final_stats = _box_label(box, "", 20, Color("dee2e6"), 110)

	restart_button = Button.new()
	UIStyle.style_button(restart_button, "Rejouer", UIStyle.ORANGE, 28)
	restart_button.pressed.connect(_restart)
	box.add_child(restart_button)

	var menu_button = Button.new()
	UIStyle.style_button(menu_button, "Menu principal", UIStyle.GREY, 22)
	menu_button.pressed.connect(_go_menu)
	box.add_child(menu_button)
	return overlay


# ---------- MISE À JOUR (appelée par main.gd) ----------

func update_stats(score, best, coins, new_lives, zone_progress, shield, magnet, slip):
	score_label.text = str(score)
	best_label.text = "RECORD %d" % max(best, score)
	coins_label.text = str(coins)
	zone_bar.size.x = 440 * zone_progress
	if new_lives != lives:
		lives = new_lives
		hearts.queue_redraw()
	shield_time = shield
	magnet_time = magnet
	powerups.queue_redraw()
	warning_label.visible = slip > 0


func set_zone(number: int, zone_name: String):
	zone_label.text = "ZONE %d  ·  %s" % [number, zone_name.to_upper()]


func show_message(text: String):
	message_label.text = text
	message_label.show()
	message_label.scale = Vector2(0.4, 0.4)
	message_label.modulate.a = 1.0
	if message_tween:
		message_tween.kill()
	message_tween = create_tween()
	message_tween.tween_property(message_label, "scale", Vector2.ONE, 0.35) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	message_tween.tween_interval(1.6)
	message_tween.tween_property(message_label, "modulate:a", 0.0, 0.4)
	message_tween.tween_callback(message_label.hide)


func show_combo(combo: int):
	combo_label.text = "COMBO x%d !" % combo
	combo_label.modulate.a = 1.0
	combo_label.scale = Vector2(1.5, 1.5)
	if combo_tween:
		combo_tween.kill()
	combo_tween = create_tween()
	combo_tween.tween_property(combo_label, "scale", Vector2.ONE, 0.2)
	combo_tween.tween_interval(0.6)
	combo_tween.tween_property(combo_label, "modulate:a", 0.0, 0.3)


func flash_screen(color: Color):
	flash.color = Color(color, 0.45)
	var tween = create_tween()
	tween.tween_property(flash, "color:a", 0.0, 0.4)


func show_game_over(score: int, distance: int, coins: int, best: int, is_record: bool):
	playing = false
	record_label.visible = is_record
	final_stats.text = "Distance : %d m\nPièces : %d\nRecord : %d" % [distance, coins, best]
	game_over_menu.modulate.a = 0.0
	game_over_menu.show()
	var tween = create_tween()
	tween.tween_property(game_over_menu, "modulate:a", 1.0, 0.3)
	# Le score défile de 0 jusqu'au score final
	tween.tween_method(func(value): final_score.text = str(int(value)), 0.0, float(score), 1.0)
	restart_button.grab_focus()


# ---------- PAUSE ET BOUTONS ----------

func _unhandled_input(event):
	if not (event is InputEventKey and event.pressed and not event.echo):
		return
	if playing and (event.keycode == KEY_P or event.keycode == KEY_ESCAPE):
		toggle_pause()
		get_viewport().set_input_as_handled()
	elif game_over_menu.visible and event.keycode == KEY_ESCAPE:
		_go_menu()


func toggle_pause():
	if not playing:
		return
	var paused = not get_tree().paused
	get_tree().paused = paused
	pause_menu.visible = paused
	if paused:
		resume_button.grab_focus()


func _restart():
	get_tree().paused = false
	restart_requested.emit()


func _go_menu():
	get_tree().paused = false
	menu_requested.emit()


# ---------- DESSINS ----------

func _draw_hearts():
	for i in 3:
		var color = UIStyle.RED if i < lives else Color(1, 1, 1, 0.15)
		UIStyle.draw_heart(hearts, Vector2(18 + i * 36, 21), 30, color)


func _draw_powerups():
	var y = 0.0
	if shield_time > 0:
		_draw_pill(Vector2(0, y), "BOUCLIER  %d" % ceil(shield_time), UIStyle.BLUE)
		y += 44
	if magnet_time > 0:
		_draw_pill(Vector2(0, y), "AIMANT  %d" % ceil(magnet_time), UIStyle.RED)


func _draw_pill(pos: Vector2, text: String, color: Color):
	powerups.draw_style_box(UIStyle.make_box(Color(color, 0.9), 18, 0), Rect2(pos, Vector2(170, 36)))
	powerups.draw_string(UIStyle.font(), pos + Vector2(14, 26), text, HORIZONTAL_ALIGNMENT_LEFT, -1, 18, UIStyle.DARK)
