extends Control

## Garage : vitrine pour choisir sa voiture.
## La voiture est présentée en grand sur un plateau tournant, avec ses statistiques.
## Flèches (ou ← →) pour changer, "Choisir" pour l'équiper.

signal closed

const CAR_CENTER = Vector2(240, 270)
const SHOW_HEIGHT = 250.0       # hauteur de la voiture dans la vitrine
const GAME_HEIGHT = 135.0       # hauteur de la voiture en jeu (voir player.gd)
const THUMB_WIDTH = 80.0
const THUMB_GAP = 8.0

var index = 0                   # voiture affichée
var time = 0.0
var textures = []
var stat_values = [0.0, 0.0, 0.0]    # valeurs affichées (animées)
var stat_targets = [0.0, 0.0, 0.0]   # valeurs à atteindre

var stage: Node2D
var car_sprite: Sprite2D
var name_label: Label
var tagline_label: Label
var stats: Control
var thumbs: Control
var choose_button: Button


func _ready():
	size = Vector2(480, 800)
	for settings in GameData.CARS:
		textures.append(load(settings.texture))

	var shade = ColorRect.new()
	shade.size = Vector2(480, 800)
	shade.color = Color(0.03, 0.04, 0.1, 0.8)
	add_child(shade)

	add_child(UIStyle.make_label("GARAGE", 44, UIStyle.YELLOW, Vector2(0, 18), Vector2(480, 60)))
	add_child(UIStyle.make_label("Choisis ta voiture", 16, Color.WHITE, Vector2(0, 72), Vector2(480, 24)))

	# Plateau tournant et projecteur (dessinés par _draw_stage)
	stage = Node2D.new()
	stage.draw.connect(_draw_stage)
	add_child(stage)

	car_sprite = Sprite2D.new()
	car_sprite.position = CAR_CENTER
	add_child(car_sprite)

	# Flèches gauche / droite
	for dir in [-1, 1]:
		var arrow = Button.new()
		UIStyle.style_button(arrow, "<" if dir < 0 else ">", UIStyle.GREY, 30)
		arrow.position = Vector2(16 if dir < 0 else 408, CAR_CENTER.y - 32)
		arrow.size = Vector2(56, 64)
		arrow.focus_mode = Control.FOCUS_NONE
		arrow.pressed.connect(_change.bind(dir))
		add_child(arrow)

	name_label = UIStyle.make_label("", 34, Color.WHITE, Vector2(0, 404), Vector2(480, 46))
	add_child(name_label)
	tagline_label = UIStyle.make_label("", 15, Color("dee2e6"), Vector2(30, 448), Vector2(420, 44))
	tagline_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	tagline_label.add_theme_constant_override("outline_size", 4)
	add_child(tagline_label)

	stats = Control.new()
	stats.position = Vector2(50, 498)
	stats.size = Vector2(380, 90)
	stats.draw.connect(_draw_stats)
	add_child(stats)

	# Miniatures de toutes les voitures (cliquables)
	thumbs = Control.new()
	var total = GameData.CARS.size() * THUMB_WIDTH + (GameData.CARS.size() - 1) * THUMB_GAP
	thumbs.position = Vector2((480 - total) / 2, 596)
	thumbs.size = Vector2(total, 64)
	thumbs.draw.connect(_draw_thumbs)
	thumbs.gui_input.connect(_on_thumbs_input)
	add_child(thumbs)

	choose_button = Button.new()
	UIStyle.style_button(choose_button, "CHOISIR", UIStyle.ORANGE, 26)
	choose_button.position = Vector2(90, 670)
	choose_button.size = Vector2(300, 58)
	choose_button.pressed.connect(_choose)
	add_child(choose_button)

	var back = Button.new()
	UIStyle.style_button(back, "Retour", UIStyle.GREY, 20)
	back.position = Vector2(90, 738)
	back.size = Vector2(300, 50)
	back.custom_minimum_size = Vector2(0, 50)
	back.pressed.connect(close)
	add_child(back)

	hide()


func open():
	index = GameData.car
	show()
	_refresh(0)
	choose_button.grab_focus()


func close():
	hide()
	closed.emit()


func _process(delta):
	if not visible:
		return
	time += delta
	# La voiture "flotte" doucement sur le plateau
	car_sprite.position.y = CAR_CENTER.y + sin(time * 2.0) * 4
	car_sprite.rotation = sin(time * 1.2) * 0.04
	for i in 3:
		stat_values[i] = lerp(stat_values[i], stat_targets[i], 8 * delta)
	stage.queue_redraw()
	stats.queue_redraw()


func _unhandled_input(event):
	if not visible:
		return
	if event.is_action_pressed("ui_left"):
		_change(-1)
	elif event.is_action_pressed("ui_right"):
		_change(1)
	elif event.is_action_pressed("ui_cancel"):
		close()
	else:
		return
	get_viewport().set_input_as_handled()


# ---------- CHANGER DE VOITURE ----------

func _change(dir: int):
	index = wrapi(index + dir, 0, GameData.CARS.size())
	_refresh(dir)


func _choose():
	GameData.car = index
	GameData.save_data()
	_refresh(0)
	# Petit "pop" de la voiture pour confirmer
	car_sprite.scale *= 1.15
	var tween = create_tween()
	tween.tween_property(car_sprite, "scale", car_sprite.scale / 1.15, 0.25).set_trans(Tween.TRANS_BACK)


# Met à jour la vitrine. dir = sens de l'animation (-1, 1 ou 0 = pas d'animation)
func _refresh(dir: int):
	var settings = GameData.CARS[index]
	var texture = textures[index]
	car_sprite.texture = texture
	var s = SHOW_HEIGHT / texture.get_height()
	car_sprite.scale = Vector2(s, s)

	name_label.text = settings.name
	name_label.add_theme_color_override("font_color", settings.color)
	tagline_label.text = settings.tagline

	# Statistiques entre 0 et 1
	var game_width = texture.get_width() * GAME_HEIGHT / texture.get_height()
	stat_targets = [
		clamp((settings.handling - 8.0) / 12.0, 0.05, 1.0),     # maniabilité
		clamp(1.0 - (game_width - 50.0) / 40.0, 0.05, 1.0),      # finesse (petite = plus facile)
		clamp(settings.shield / 10.0, 0.0, 1.0),                 # protection
	]

	if index == GameData.car:
		choose_button.text = "ÉQUIPÉE"
		UIStyle.recolor_button(choose_button, UIStyle.GREEN.darkened(0.25))
	else:
		choose_button.text = "CHOISIR"
		UIStyle.recolor_button(choose_button, UIStyle.ORANGE)

	# La voiture arrive en glissant depuis le côté
	if dir != 0:
		car_sprite.position.x = CAR_CENTER.x + dir * 320
		var tween = create_tween()
		tween.tween_property(car_sprite, "position:x", CAR_CENTER.x, 0.35) \
			.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	thumbs.queue_redraw()


# ---------- DESSINS ----------

func _draw_stage():
	var color = GameData.CARS[index].color
	# Faisceau du projecteur
	stage.draw_colored_polygon(PackedVector2Array([
		Vector2(200, 96), Vector2(280, 96), Vector2(420, 420), Vector2(60, 420),
	]), Color(1, 1, 1, 0.04))
	# Halo coloré
	stage.draw_circle(CAR_CENTER, 175, Color(color, 0.10))
	stage.draw_circle(CAR_CENTER, 158, Color(color, 0.12))
	# Plateau tournant
	stage.draw_circle(CAR_CENTER, 145, Color(0.1, 0.11, 0.18, 0.95))
	stage.draw_arc(CAR_CENTER, 145, 0, TAU, 64, Color(color, 0.9), 3)
	stage.draw_arc(CAR_CENTER, 118, 0, TAU, 64, Color(1, 1, 1, 0.08), 2)
	for i in 24:
		var angle = time * 0.6 + i * TAU / 24.0
		stage.draw_arc(CAR_CENTER, 132, angle, angle + 0.12, 4, Color(color, 0.7), 4)


func _draw_stats():
	var names = ["MANIABILITÉ", "FINESSE", "PROTECTION"]
	var color = GameData.CARS[index].color
	for i in 3:
		var y = i * 30.0
		stats.draw_string(UIStyle.font(), Vector2(0, y + 19), names[i],
			HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color.WHITE)
		var bar = Rect2(140, y + 6, 240, 14)
		stats.draw_style_box(UIStyle.make_box(Color(1, 1, 1, 0.1), 7, 0), bar)
		if stat_values[i] > 0.02:
			stats.draw_style_box(UIStyle.make_box(color, 7, 0),
				Rect2(bar.position, Vector2(bar.size.x * stat_values[i], bar.size.y)))


func _draw_thumbs():
	for i in GameData.CARS.size():
		var slot = Rect2(i * (THUMB_WIDTH + THUMB_GAP), 0, THUMB_WIDTH, 64)
		var box = UIStyle.make_box(Color(1, 1, 1, 0.12) if i == index else Color(0, 0, 0, 0.35), 12, 0)
		if i == index:
			box.border_color = GameData.CARS[i].color
			box.set_border_width_all(3)
		thumbs.draw_style_box(box, slot)
		# Voiture en miniature (tournée sur le côté pour mieux remplir la case)
		var texture = textures[i]
		var s = 52.0 / texture.get_height()
		var car_size = texture.get_size() * s
		thumbs.draw_set_transform(slot.get_center(), PI / 2, Vector2.ONE)
		thumbs.draw_texture_rect(texture, Rect2(-car_size / 2, car_size), false)
		thumbs.draw_set_transform(Vector2.ZERO, 0, Vector2.ONE)
		# Point vert sur la voiture équipée
		if i == GameData.car:
			thumbs.draw_circle(slot.position + Vector2(THUMB_WIDTH - 10, 10), 6, UIStyle.GREEN)


func _on_thumbs_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var clicked = int(event.position.x / (THUMB_WIDTH + THUMB_GAP))
		if clicked >= 0 and clicked < GameData.CARS.size() and clicked != index:
			var dir = 1 if clicked > index else -1
			index = clicked
			_refresh(dir)
