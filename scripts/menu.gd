extends Control

var car_texture = preload("res://assets/car_red_1.png")

func _ready():
	size = Vector2(480, 800)
	$Box/PlayButton.pressed.connect(_on_play)
	$Box/QuitButton.pressed.connect(_on_quit)
	setup_design()
	# Permet de choisir avec les flèches et Entrée
	$Box/PlayButton.grab_focus()

func _on_play():
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_quit():
	get_tree().quit()

# ---------- DESIGN ----------

func setup_design():
	# Titre
	var title = $Title
	title.text = "DODGE\nCARS"
	title.position = Vector2(0, 110)
	title.size = Vector2(480, 200)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 72)
	title.add_theme_color_override("font_color", Color("ffd94a"))
	title.add_theme_color_override("font_outline_color", Color.BLACK)
	title.add_theme_constant_override("outline_size", 14)

	# Boutons
	$Box.position = Vector2(115, 380)
	$Box.size = Vector2(250, 160)
	$Box.add_theme_constant_override("separation", 20)
	style_button($Box/PlayButton, "Jouer", Color("e8641b"))
	style_button($Box/QuitButton, "Quitter", Color("444444"))

func style_button(button, text, color):
	button.text = text
	button.add_theme_font_size_override("font_size", 30)
	button.add_theme_stylebox_override("normal", make_box(color))
	button.add_theme_stylebox_override("hover", make_box(color.lightened(0.2)))
	button.add_theme_stylebox_override("pressed", make_box(color.darkened(0.2)))
	# Contour blanc quand le bouton est choisi au clavier
	var focus = StyleBoxFlat.new()
	focus.draw_center = false
	focus.set_border_width_all(3)
	focus.border_color = Color.WHITE
	focus.set_corner_radius_all(12)
	button.add_theme_stylebox_override("focus", focus)

func make_box(color):
	var box = StyleBoxFlat.new()
	box.bg_color = color
	box.set_corner_radius_all(12)
	box.set_content_margin_all(12)
	return box

func _draw():
	
	draw_rect(Rect2(0, 0, 480, 800), Color("3a7d44"))
	
	draw_rect(Rect2(120, 0, 240, 800), Color("555555"))
	draw_rect(Rect2(120, 0, 6, 800), Color.WHITE)
	draw_rect(Rect2(354, 0, 6, 800), Color.WHITE)
	
	var y = 0
	while y < 800:
		draw_rect(Rect2(237, y, 6, 40), Color.WHITE)
		y += 80
	
	draw_texture(car_texture, Vector2(240 - car_texture.get_width() / 2.0, 620))
