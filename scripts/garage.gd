extends Control

## Garage (scène garage.tscn) : vitrine pour choisir sa voiture.
## La voiture est présentée en grand sur un plateau tournant, avec ses statistiques.
## Flèches (ou ← →) pour changer, "Choisir" pour l'équiper.

signal closed

const CAR_CENTER = Vector2(240, 270)   # position de la voiture dans la vitrine
const SHOW_HEIGHT = 250.0              # hauteur de la voiture dans la vitrine
const GAME_HEIGHT = 135.0              # hauteur de la voiture en jeu (voir player.gd)

var index = 0      # voiture affichée
var time = 0.0
var textures = []


# Charge les images des voitures et relie les boutons de la scène
func _ready():
	for settings in GameData.CARS:
		textures.append(load(settings.texture))
	%LeftArrow.pressed.connect(_change.bind(-1))
	%RightArrow.pressed.connect(_change.bind(1))
	%ChooseButton.pressed.connect(_choose)
	%BackButton.pressed.connect(close)
	%Thumbs.car_clicked.connect(_on_thumb_clicked)
	hide()


# Ouvre le garage sur la voiture actuellement équipée
func open():
	index = GameData.car
	show()
	_refresh(0)
	%ChooseButton.grab_focus()


# Ferme le garage et prévient le menu (signal "closed")
func close():
	hide()
	closed.emit()


# À chaque image : la voiture "flotte" doucement sur le plateau
func _process(delta):
	if not visible:
		return
	time += delta
	%CarSprite.position.y = CAR_CENTER.y + sin(time * 2.0) * 4
	%CarSprite.rotation = sin(time * 1.2) * 0.04


# Clavier : ← → pour changer de voiture, Échap pour revenir au menu
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

# Passe à la voiture précédente (-1) ou suivante (+1)
func _change(dir: int):
	index = wrapi(index + dir, 0, GameData.CARS.size())
	_refresh(dir)


# Clic sur une miniature : on affiche cette voiture
func _on_thumb_clicked(clicked: int):
	if clicked != index:
		var dir = 1 if clicked > index else -1
		index = clicked
		_refresh(dir)


# Équipe la voiture affichée et sauvegarde ce choix
func _choose():
	GameData.car = index
	GameData.save_data()
	_refresh(0)
	# Petit "pop" de la voiture pour confirmer
	var normal_scale = %CarSprite.scale
	%CarSprite.scale = normal_scale * 1.15
	var tween = create_tween()
	tween.tween_property(%CarSprite, "scale", normal_scale, 0.25).set_trans(Tween.TRANS_BACK)


# Met à jour la vitrine. dir = sens de l'animation (-1, 1 ou 0 = pas d'animation)
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

	# Statistiques entre 0 et 1
	var game_width = texture.get_width() * GAME_HEIGHT / texture.get_height()
	%Stats.set_stats([
		clamp((settings.handling - 8.0) / 12.0, 0.05, 1.0),   # maniabilité
		clamp(1.0 - (game_width - 50.0) / 40.0, 0.05, 1.0),    # finesse (petite = plus facile)
		clamp(settings.shield / 10.0, 0.0, 1.0),               # protection
	], settings.color)
	%Thumbs.set_selection(index, GameData.car)

	# Le bouton change de texte et de couleur (style du thème) si la voiture est déjà équipée
	if index == GameData.car:
		%ChooseButton.text = "ÉQUIPÉE"
		%ChooseButton.theme_type_variation = &"GreenButton"
	else:
		%ChooseButton.text = "CHOISIR"
		%ChooseButton.theme_type_variation = &"OrangeButton"

	# La voiture arrive en glissant depuis le côté
	if dir != 0:
		%CarSprite.position.x = CAR_CENTER.x + dir * 320
		var tween = create_tween()
		tween.tween_property(%CarSprite, "position:x", CAR_CENTER.x, 0.35) \
			.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
