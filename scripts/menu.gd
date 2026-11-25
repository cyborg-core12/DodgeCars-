extends Control

# Menu principal

var time = 0.0


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
	%PlayButton.grab_focus()


func _process(delta):
	time += delta
	%Title.position.y = 60 + sin(time * 2.0) * 6
	%Title.rotation = -0.05 + sin(time * 1.3) * 0.02
	%MenuCar.position.x = 240 + sin(time * 0.9) * 110
	%MenuCar.rotation = cos(time * 0.9) * 0.54


func _update_car():
	%MenuCar.show_car(load(GameData.car_settings().texture))


func _set_main_visible(value: bool):
	for node in [%Box, %Title, %Subtitle, %RecordPanel, %MenuCar]:
		node.visible = value


func _on_play():
	_set_main_visible(false)
	%Title.show()
	%LevelSelect.open()


func _on_back():
	%LevelSelect.hide()
	_set_main_visible(true)
	%PlayButton.grab_focus()


func _on_garage():
	_set_main_visible(false)
	%Garage.open()


func _on_garage_closed():
	_set_main_visible(true)
	_update_car()
	%GarageButton.grab_focus()


# Lance le niveau choisi
func _start_level(number: int):
	GameData.level = number
	get_tree().change_scene_to_file("res://scenes/main.tscn")


func _on_quit():
	get_tree().quit()
