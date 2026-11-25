extends Control

## Menu principal : route animée en fond, titre, record et boutons.

var car_texture = preload("res://assets/car_red_1.png")
var road: Road
var car: Node2D
var time = 0.0


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
	# Permet de choisir avec les flèches et Entrée
	$Box/PlayButton.grab_focus()


func _process(delta):
	time += delta
	# Le titre flotte doucement
	$Title.position.y = 60 + sin(time * 2.0) * 6
	$Title.rotation = -0.05 + sin(time * 1.3) * 0.02
	# La voiture zigzague entre les voies
	car.position.x = 240 + sin(time * 0.9) * 110
	car.rotation = cos(time * 0.9) * 0.6 * 0.9


func _on_play():
	get_tree().change_scene_to_file("res://scenes/main.tscn")


func _on_quit():
	get_tree().quit()


# ---------- DESIGN ----------

func _create_car():
	car = Node2D.new()
	car.position = Vector2(240, 690)
	car.draw.connect(func(): car.draw_rect(Rect2(-35 + 6, -65 + 8, 71, 131), Color(0, 0, 0, 0.3)))
	var sprite = Sprite2D.new()
	sprite.texture = car_texture
	car.add_child(sprite)
	add_child(car)
	move_child(car, 2)


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

	add_child(UIStyle.make_label("ÉVITE  ·  RAMASSE  ·  SURVIS", 18, Color.WHITE, Vector2(0, 300), Vector2(480, 30)))

	# Boutons
	$Box.position = Vector2(100, 360)
	$Box.size = Vector2(280, 150)
	$Box.add_theme_constant_override("separation", 18)
	UIStyle.style_button($Box/PlayButton, "JOUER", UIStyle.ORANGE, 34)
	UIStyle.style_button($Box/QuitButton, "QUITTER", UIStyle.GREY, 24)

	# Record et pièces sauvegardés
	var panel = UIStyle.make_panel(Vector2(90, 530), Vector2(300, 66))
	add_child(panel)
	panel.add_child(UIStyle.make_label("RECORD : %d" % GameData.best_score, 22, UIStyle.YELLOW, Vector2(0, 6), Vector2(300, 30)))
	panel.add_child(UIStyle.make_label("PIÈCES GAGNÉES : %d" % GameData.total_coins, 14, Color.WHITE, Vector2(0, 38), Vector2(300, 20)))

	var hint = UIStyle.make_label("← → / Q D : changer de voie   ·   P : pause", 14, Color.WHITE, Vector2(0, 765), Vector2(480, 26))
	hint.add_theme_constant_override("outline_size", 4)
	add_child(hint)
