extends Control

# Choix du niveau

signal level_chosen(number)
signal back_pressed


func _ready():
	for i in GameData.LEVELS.size():
		var button = get_node("%%Level%dButton" % (i + 1))
		button.pressed.connect(level_chosen.emit.bind(i + 1))
	%BackButton.pressed.connect(back_pressed.emit)
	hide()


func open():
	for i in GameData.LEVELS.size():
		var settings = GameData.LEVELS[i]
		get_node("%%Level%dButton" % (i + 1)).text = "NIVEAU %d  ·  %s" % [i + 1, settings.name]
		var stars = GameData.best_stars[i]
		var done = "Étoiles : %d/3" % stars if stars > 0 else "Pas encore terminé"
		get_node("%%Level%dInfo" % (i + 1)).text = "%s\n%s  ·  Record : %d" % [
			settings.description, done, GameData.best_scores[i]]
	show()
	get_node("%%Level%dButton" % GameData.level).grab_focus()


func _unhandled_input(event):
	if visible and event.is_action_pressed("ui_cancel"):
		back_pressed.emit()
		get_viewport().set_input_as_handled()
