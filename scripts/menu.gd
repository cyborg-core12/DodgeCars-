extends Control

## Menu principal : route animée en fond, titre, record et boutons.

var road: Road
var car: Node2D                # voiture qui roule en bas du menu
var car_sprite: Sprite2D
var subtitle: Label
var record_panel: Panel
var garage_button: Button
var garage: Control            # écran Garage (voir garage.gd)
var level_box: VBoxContainer   # écran de choix du niveau
var level_buttons = []
var time = 0.0


# Au lancement du menu : route animée, voiture, boutons et garage
func _ready():
	get_tree().paused = false

	# La route du jeu défile derrière le menu
	road = preload("res://scripts/road.gd").new()
	road.speed = 260.0
	add_child(road)
	move_child(road, 0)

	# Voile sombre pour que le texte reste lisible
	var shade = ColorRect.new()
	shade.size = Vector2(480, 800)
	shade.color = Color(0.05, 0.06, 0.12, 0.35)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(shade)
	move_child(shade, 1)

	_create_car()
	$Box/PlayButton.pressed.connect(_on_play)
	$Box/QuitButton.pressed.connect(_on_quit)
	setup_design()

	garage = preload("res://scripts/garage.gd").new()
	add_child(garage)
	garage.closed.connect(_on_garage_closed)

	# Permet de choisir avec les flèches et Entrée
	$Box/PlayButton.grab_focus()


# À chaque image : le titre flotte et la voiture zigzague
func _process(delta):
	time += delta
	# Le titre flotte doucement
	$Title.position.y = 60 + sin(time * 2.0) * 6
	$Title.rotation = -0.05 + sin(time * 1.3) * 0.02
	# La voiture zigzague entre les voies
	car.position.x = 240 + sin(time * 0.9) * 110
	car.rotation = cos(time * 0.9) * 0.6 * 0.9


# "Jouer" ouvre le choix du niveau
func _on_play():
	$Box.hide()
	record_panel.hide()
	car.hide()
	level_box.show()
	level_buttons[GameData.level - 1].grab_focus()


# Retour depuis le choix du niveau vers le menu principal
func _on_back():
	level_box.hide()
	$Box.show()
	record_panel.show()
	car.show()
	$Box/PlayButton.grab_focus()


# "Garage" ouvre la vitrine des voitures
func _on_garage():
	_set_main_visible(false)
	garage.open()


# Le garage est fermé : on réaffiche le menu avec la nouvelle voiture
func _on_garage_closed():
	_set_main_visible(true)
	_update_car()
	garage_button.grab_focus()


# Affiche ou cache les éléments du menu principal
func _set_main_visible(value: bool):
	for node in [$Box, $Title, subtitle, record_panel, car]:
		node.visible = value


# Lance le niveau choisi
func _start_level(number: int):
	GameData.level = number
	get_tree().change_scene_to_file("res://scenes/main.tscn")


# Échap dans le choix du niveau = retour
func _unhandled_input(event):
	if level_box.visible and event.is_action_pressed("ui_cancel"):
		_on_back()


# Bouton Quitter : ferme le jeu
func _on_quit():
	get_tree().quit()


# ---------- DESIGN ----------

func _create_car():
	car = Node2D.new()
	car.position = Vector2(240, 700)
	car.draw.connect(_draw_car_shadow)
	car_sprite = Sprite2D.new()
	car.add_child(car_sprite)
	add_child(car)
	move_child(car, 2)
	_update_car()


# Affiche la voiture choisie dans le garage, à la même taille qu'en jeu
func _update_car():
	var texture = load(GameData.car_settings().texture)
	car_sprite.texture = texture
	var s = 135.0 / texture.get_height()
	car_sprite.scale = Vector2(s, s)
	car.queue_redraw()


# Dessine l'ombre sous la voiture du menu
func _draw_car_shadow():
	var car_size = car_sprite.texture.get_size() * car_sprite.scale
	car.draw_rect(Rect2(-car_size / 2 + Vector2(6, 8), car_size), Color(0, 0, 0, 0.3))


# Met en forme le titre, les boutons et le panneau des records
func setup_design():
	var title = $Title
	title.text = "DODGE\nCARS"
	title.size = Vector2(480, 240)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	UIStyle.style_label(title, 88, UIStyle.YELLOW, 18)
	title.add_theme_constant_override("line_spacing", -22)
	title.add_theme_constant_override("shadow_offset_y", 8)
	title.pivot_offset = Vector2(240, 120)

	subtitle = UIStyle.make_label("ÉVITE  ·  RAMASSE  ·  SURVIS", 18, Color.WHITE, Vector2(0, 300), Vector2(480, 30))
	add_child(subtitle)

	# Boutons : Jouer, Garage, Quitter
	$Box.position = Vector2(100, 345)
	$Box.size = Vector2(280, 200)
	$Box.add_theme_constant_override("separation", 14)
	UIStyle.style_button($Box/PlayButton, "JOUER", UIStyle.ORANGE, 34)
	garage_button = Button.new()
	UIStyle.style_button(garage_button, "GARAGE", UIStyle.BLUE.darkened(0.2), 26)
	garage_button.custom_minimum_size = Vector2(0, 56)
	garage_button.pressed.connect(_on_garage)
	$Box.add_child(garage_button)
	$Box.move_child(garage_button, 1)
	UIStyle.style_button($Box/QuitButton, "QUITTER", UIStyle.GREY, 24)
	$Box/QuitButton.custom_minimum_size = Vector2(0, 56)

	# Meilleur record (tous niveaux) et pièces sauvegardées
	record_panel = UIStyle.make_panel(Vector2(90, 560), Vector2(300, 66))
	add_child(record_panel)
	record_panel.add_child(UIStyle.make_label("RECORD : %d" % GameData.best_scores.max(), 22, UIStyle.YELLOW, Vector2(0, 6), Vector2(300, 30)))
	record_panel.add_child(UIStyle.make_label("PIÈCES GAGNÉES : %d" % GameData.total_coins, 14, Color.WHITE, Vector2(0, 38), Vector2(300, 20)))

	_build_level_select()


# Écran de choix du niveau : un bouton par niveau, avec sa description et son record
func _build_level_select():
	level_box = VBoxContainer.new()
	level_box.position = Vector2(60, 318)
	level_box.size = Vector2(360, 440)
	level_box.add_theme_constant_override("separation", 4)
	add_child(level_box)

	var title = UIStyle.make_label("CHOISIS TON NIVEAU", 24, Color.WHITE, Vector2.ZERO, Vector2.ZERO)
	title.custom_minimum_size = Vector2(0, 44)
	level_box.add_child(title)

	for i in GameData.LEVELS.size():
		var settings = GameData.LEVELS[i]
		var button = Button.new()
		UIStyle.style_button(button, "NIVEAU %d  ·  %s" % [i + 1, settings.name], settings.color, 24)
		button.pressed.connect(_start_level.bind(i + 1))
		level_box.add_child(button)
		level_buttons.append(button)

		var stars = GameData.best_stars[i]
		var done = "Étoiles : %d/3" % stars if stars > 0 else "Pas encore terminé"
		var info = UIStyle.make_label("%s\n%s  ·  Record : %d" % [settings.description, done, GameData.best_scores[i]],
			13, Color("dee2e6"), Vector2.ZERO, Vector2.ZERO)
		info.add_theme_constant_override("outline_size", 4)
		info.custom_minimum_size = Vector2(0, 40)
		level_box.add_child(info)

	var back = Button.new()
	UIStyle.style_button(back, "Retour", UIStyle.GREY, 20)
	back.custom_minimum_size = Vector2(0, 50)
	back.pressed.connect(_on_back)
	level_box.add_child(back)
	level_box.hide()

	var hint = UIStyle.make_label("← → / Q D : changer de voie   ·   P : pause", 14, Color.WHITE, Vector2(0, 765), Vector2(480, 26))
	hint.add_theme_constant_override("outline_size", 4)
	add_child(hint)
