extends CanvasLayer

## Interface du jeu : score, vies, pièces, bonus actifs, messages,
## menu pause et écran de fin. Tous les éléments sont créés par le code.

signal restart_requested
signal menu_requested
signal next_requested

var playing = true
var max_lives = 3
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
var final_title: Label
var stars_display: Control
var record_label: Label
var final_score: Label
var final_stats: Label
var next_button: Button
var restart_button: Button
var stars = 0
var level_text = ""

var message_tween: Tween
var combo_tween: Tween


# Crée tous les éléments de l'interface au lancement de la partie
func _ready():
	# Le HUD continue de fonctionner quand le jeu est en pause
	process_mode = Node.PROCESS_MODE_ALWAYS
	_build_top_bar()
	_build_messages()
	pause_menu = _build_pause_menu()
	game_over_menu = _build_game_over()


# À chaque image : fait clignoter le message de record et l'alerte d'huile
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


# Crée les messages au centre de l'écran (zone, combo, alerte, aide, flash rouge)
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


# Crée un fond sombre qui recouvre tout l'écran (pour la pause et la fin)
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


# Crée une colonne (VBoxContainer) qui range les éléments d'un menu
func _make_menu_box(card: Panel, box_size: Vector2) -> VBoxContainer:
	var box = VBoxContainer.new()
	box.position = Vector2(30, 24)
	box.size = box_size
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 14)
	card.add_child(box)
	return box


# Ajoute un texte dans une colonne de menu
func _box_label(box: VBoxContainer, text: String, font_size: int, color: Color, height: float) -> Label:
	var label = UIStyle.make_label(text, font_size, color, Vector2.ZERO, Vector2.ZERO)
	label.custom_minimum_size = Vector2(0, height)
	box.add_child(label)
	return label


# Crée le menu pause : titre, bouton Reprendre et bouton Menu
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


# Écran de fin, utilisé pour la victoire ET le game over
func _build_game_over() -> Control:
	var overlay = _make_overlay()
	var card = UIStyle.make_panel(Vector2(30, 90), Vector2(420, 640))
	overlay.add_child(card)
	var box = _make_menu_box(card, Vector2(360, 592))
	box.add_theme_constant_override("separation", 10)
	final_title = _box_label(box, "GAME OVER", 46, UIStyle.RED, 64)

	stars_display = Control.new()
	stars_display.custom_minimum_size = Vector2(0, 60)
	stars_display.draw.connect(_draw_stars)
	box.add_child(stars_display)

	record_label = _box_label(box, "NOUVEAU RECORD !", 22, UIStyle.YELLOW, 30)
	final_score = _box_label(box, "0", 60, Color.WHITE, 72)
	final_stats = _box_label(box, "", 18, Color("dee2e6"), 90)

	next_button = Button.new()
	UIStyle.style_button(next_button, "Niveau suivant", UIStyle.GREEN, 26)
	next_button.pressed.connect(func():
		get_tree().paused = false
		next_requested.emit())
	box.add_child(next_button)

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

func update_stats(score, best, coins, new_lives, distance, goal, shield, magnet, slip):
	score_label.text = str(score)
	best_label.text = "RECORD %d" % max(best, score)
	coins_label.text = str(coins)
	# Progression vers la ligne d'arrivée
	zone_bar.size.x = 440 * clamp(distance / goal, 0.0, 1.0)
	zone_label.text = "%s   ·   %d / %d m" % [level_text, min(distance, goal), goal]
	if new_lives != lives:
		lives = new_lives
		hearts.queue_redraw()
	shield_time = shield
	magnet_time = magnet
	powerups.queue_redraw()
	warning_label.visible = slip > 0


# Affiche le nom du niveau et colore la barre de progression
func set_level(number: int, level_name: String, zone_name: String, color: Color):
	level_text = "NIVEAU %d  ·  %s  ·  %s" % [number, level_name, zone_name.to_upper()]
	zone_label.text = level_text
	# La barre de progression prend la couleur du niveau
	zone_bar.add_theme_stylebox_override("panel", UIStyle.make_box(color, 5, 0))


# Affiche un grand message au centre qui "pop" puis disparaît
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


# Affiche "COMBO xN !" quand on enchaîne les pièces
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


# Fait flasher l'écran d'une couleur (rouge quand on est touché)
func flash_screen(color: Color):
	flash.color = Color(color, 0.45)
	var tween = create_tween()
	tween.tween_property(flash, "color:a", 0.0, 0.4)


# Affiche l'écran de défaite avec la distance parcourue
func show_game_over(score: int, distance: int, goal: int, coins: int, best: int, is_record: bool):
	final_title.text = "GAME OVER"
	final_title.add_theme_color_override("font_color", UIStyle.RED)
	stars = 0
	stars_display.hide()
	next_button.hide()
	final_stats.text = "Niveau %d (%s)\nTu as fait %d m sur %d m\nPièces : %d  ·  Record : %d" % [
		GameData.level, GameData.settings().name, distance, goal, coins, best]
	_show_end_screen(score, is_record)


# Affiche l'écran de victoire avec les étoiles gagnées
func show_victory(score: int, new_stars: int, coins: int, best: int, is_record: bool, has_next: bool):
	final_title.text = "NIVEAU RÉUSSI !"
	final_title.add_theme_color_override("font_color", UIStyle.GREEN)
	stars = new_stars
	stars_display.show()
	stars_display.queue_redraw()
	next_button.visible = has_next
	var hint = "Aucune vie perdue, parfait !" if new_stars == 3 else "Perds moins de vies pour 3 étoiles"
	final_stats.text = "Niveau %d (%s)\n%s\nPièces : %d  ·  Record : %d" % [
		GameData.level, GameData.settings().name, hint, coins, best]
	_show_end_screen(score, is_record)


# Partie commune aux deux écrans de fin : apparition et score qui défile
func _show_end_screen(score: int, is_record: bool):
	playing = false
	record_label.visible = is_record
	game_over_menu.modulate.a = 0.0
	game_over_menu.show()
	var tween = create_tween()
	tween.tween_property(game_over_menu, "modulate:a", 1.0, 0.3)
	# Le score défile de 0 jusqu'au score final
	tween.tween_method(func(value): final_score.text = str(int(value)), 0.0, float(score), 1.0)
	if next_button.visible:
		next_button.grab_focus()
	else:
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


# Met le jeu en pause ou le relance
func toggle_pause():
	if not playing:
		return
	var paused = not get_tree().paused
	get_tree().paused = paused
	pause_menu.visible = paused
	if paused:
		resume_button.grab_focus()


# Bouton Rejouer : enlève la pause et prévient main.gd
func _restart():
	get_tree().paused = false
	restart_requested.emit()


# Bouton Menu : enlève la pause et prévient main.gd
func _go_menu():
	get_tree().paused = false
	menu_requested.emit()


# ---------- DESSINS ----------

func _draw_hearts():
	for i in max_lives:
		var color = UIStyle.RED if i < lives else Color(1, 1, 1, 0.15)
		UIStyle.draw_heart(hearts, Vector2(18 + i * 36, 21), 30, color)


# Dessine les 3 étoiles de l'écran de victoire (jaunes = gagnées)
func _draw_stars():
	var center_x = stars_display.size.x / 2
	for i in 3:
		var color = UIStyle.YELLOW if i < stars else Color(1, 1, 1, 0.15)
		draw_star(stars_display, Vector2(center_x + (i - 1) * 62, 30), 26, color)


# Dessine une étoile à 5 branches (10 points : pointes et creux en alternance)
static func draw_star(canvas: CanvasItem, center: Vector2, radius: float, color: Color):
	var points = PackedVector2Array()
	for i in 10:
		var r = radius if i % 2 == 0 else radius * 0.45
		var angle = -PI / 2 + i * PI / 5
		points.append(center + Vector2(cos(angle), sin(angle)) * r)
	canvas.draw_colored_polygon(points, color)


# Dessine les bonus actifs (bouclier, aimant) avec leur temps restant
func _draw_powerups():
	var y = 0.0
	if shield_time > 0:
		_draw_pill(Vector2(0, y), "BOUCLIER  %d" % ceil(shield_time), UIStyle.BLUE)
		y += 44
	if magnet_time > 0:
		_draw_pill(Vector2(0, y), "AIMANT  %d" % ceil(magnet_time), UIStyle.RED)


# Dessine une "pastille" colorée avec un texte dedans
func _draw_pill(pos: Vector2, text: String, color: Color):
	powerups.draw_style_box(UIStyle.make_box(Color(color, 0.9), 18, 0), Rect2(pos, Vector2(170, 36)))
	powerups.draw_string(UIStyle.font(), pos + Vector2(14, 26), text, HORIZONTAL_ALIGNMENT_LEFT, -1, 18, UIStyle.DARK)
