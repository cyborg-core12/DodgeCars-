extends Control

# Garage : choix de la voiture

signal closed

const CAR_CENTER = Vector2(240, 270)
const SHOW_HEIGHT = 250.0
const GAME_HEIGHT = 135.0

var index = 0
var time = 0.0
var textures = []


func _ready():
	for settings in GameData.CARS:
		textures.append(load(settings.texture))
	%LeftArrow.pressed.connect(_change.bind(-1))
	%RightArrow.pressed.connect(_change.bind(1))
	%ChooseButton.pressed.connect(_choose)
	%BackButton.pressed.connect(close)
	%Thumbs.car_clicked.connect(_on_thumb_clicked)
	hide()


func open():
	index = GameData.car
	show()
	_refresh(0)
	%ChooseButton.grab_focus()


func close():
	hide()
	closed.emit()


func _process(delta):
	if not visible:
		return
	time += delta
	%CarSprite.position.y = CAR_CENTER.y + sin(time * 2.0) * 4
	%CarSprite.rotation = sin(time * 1.2) * 0.04


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


func _change(dir: int):
	index = wrapi(index + dir, 0, GameData.CARS.size())
	_refresh(dir)


func _on_thumb_clicked(clicked: int):
	if clicked != index:
		var dir = 1 if clicked > index else -1
		index = clicked
		_refresh(dir)


# Équipe la voiture et sauvegarde le choix
func _choose():
	GameData.car = index
	GameData.save_data()
	_refresh(0)
	var normal_scale = %CarSprite.scale
	%CarSprite.scale = normal_scale * 1.15
	var tween = create_tween()
	tween.tween_property(%CarSprite, "scale", normal_scale, 0.25).set_trans(Tween.TRANS_BACK)


# Met à jour l'affichage de la voiture sélectionnée
func _refresh(dir: int):
	var settings = GameData.CARS[index]
	var texture = textures[index]
	%CarSprite.texture = texture
	var s = SHOW_HEIGHT / texture.get_height()
	%CarSprite.scale = Vector2(s, s)

	%NameLabel.text = settings.name
	%NameLabel.add_theme_color_override("font_color", settings.color)
	%TaglineLabel.text = settings.tagline
	%Turntable.color = settings.color

	var game_width = texture.get_width() * GAME_HEIGHT / texture.get_height()
	%Stats.set_stats([
		clamp((settings.handling - 8.0) / 12.0, 0.05, 1.0),
		clamp(1.0 - (game_width - 50.0) / 40.0, 0.05, 1.0),
		clamp(settings.shield / 10.0, 0.0, 1.0),
	], settings.color)
	%Thumbs.set_selection(index, GameData.car)

	if index == GameData.car:
		%ChooseButton.text = "ÉQUIPÉE"
		%ChooseButton.theme_type_variation = &"GreenButton"
	else:
		%ChooseButton.text = "CHOISIR"
		%ChooseButton.theme_type_variation = &"OrangeButton"

	if dir != 0:
		%CarSprite.position.x = CAR_CENTER.x + dir * 320
		var tween = create_tween()
		tween.tween_property(%CarSprite, "position:x", CAR_CENTER.x, 0.35) \
			.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
