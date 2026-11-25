extends Control

## Menu principal (scène menu.tscn) : route animée en fond, titre, boutons et records.
## Contient aussi l'écran de choix du niveau et le garage (deux sous-scènes).

var time = 0.0


# Au lancement du menu : relie les boutons, affiche les records et la voiture choisie
func _ready():
	get_tree().paused = false
	%PlayButton.pressed.connect(_on_play)
	%GarageButton.pressed.connect(_on_garage)
	%QuitButton.pressed.connect(_on_quit)
	%LevelSelect.level_chosen.connect(_start_level)
	%LevelSelect.back_pressed.connect(_on_back)
	%Garage.closed.connect(_on_garage_closed)

	%RecordLabel.text = "RECORD : %d" % GameData.best_scores.max()
	%CoinsLabel.text = "PIÈCES GAGNÉES : %d" % GameData.total_coins
	_update_car()
	# Permet de choisir avec les flèches et Entrée
	%PlayButton.grab_focus()


# À chaque image : le titre flotte et la voiture zigzague entre les voies
func _process(delta):
	time += delta
	%Title.position.y = 60 + sin(time * 2.0) * 6
	%Title.rotation = -0.05 + sin(time * 1.3) * 0.02
	%MenuCar.position.x = 240 + sin(time * 0.9) * 110
	%MenuCar.rotation = cos(time * 0.9) * 0.54


# Affiche la voiture choisie dans le garage
func _update_car():
	%MenuCar.show_car(load(GameData.car_settings().texture))


# Affiche ou cache les éléments du menu principal
func _set_main_visible(value: bool):
	for node in [%Box, %Title, %Subtitle, %RecordPanel, %MenuCar]:
		node.visible = value


# "Jouer" ouvre le choix du niveau
func _on_play():
	_set_main_visible(false)
	%Title.show()
	%LevelSelect.open()


# Retour depuis le choix du niveau vers le menu principal
func _on_back():
	%LevelSelect.hide()
	_set_main_visible(true)
	%PlayButton.grab_focus()


# "Garage" ouvre la vitrine des voitures
func _on_garage():
	_set_main_visible(false)
	%Garage.open()


# Le garage est fermé : on réaffiche le menu avec la nouvelle voiture
func _on_garage_closed():
	_set_main_visible(true)
	_update_car()
	%GarageButton.grab_focus()


# Lance le niveau choisi
func _start_level(number: int):
	GameData.level = number
	get_tree().change_scene_to_file("res://scenes/main.tscn")


# Bouton Quitter : ferme le jeu
func _on_quit():
	get_tree().quit()
