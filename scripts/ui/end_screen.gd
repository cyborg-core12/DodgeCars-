extends Control

# Écran de fin (victoire ou game over)

signal next_pressed
signal restart_pressed
signal menu_pressed

var time = 0.0


func _ready():
	%NextButton.pressed.connect(next_pressed.emit)
	%RestartButton.pressed.connect(restart_pressed.emit)
	%MenuButton.pressed.connect(menu_pressed.emit)
	hide()


func _process(delta):
	time += delta
	if %RecordLabel.visible:
		%RecordLabel.modulate.a = 0.6 + 0.4 * sin(time * 8.0)


func show_game_over(score: int, distance: int, goal: int, coins: int, best: int, is_record: bool):
	%TitleLabel.text = "GAME OVER"
	%TitleLabel.add_theme_color_override("font_color", UIStyle.RED)
	%Stars.hide()
	%NextButton.hide()
	%StatsLabel.text = "Niveau %d (%s)\nTu as fait %d m sur %d m\nPièces : %d  ·  Record : %d" % [
		GameData.level, GameData.settings().name, distance, goal, coins, best]
	_open(score, is_record)


func show_victory(score: int, stars: int, coins: int, best: int, is_record: bool, has_next: bool):
	%TitleLabel.text = "NIVEAU RÉUSSI !"
	%TitleLabel.add_theme_color_override("font_color", UIStyle.GREEN)
	%Stars.show()
	%Stars.set_stars(stars)
	%NextButton.visible = has_next
	var hint = "Aucune vie perdue, parfait !" if stars == 3 else "Perds moins de vies pour 3 étoiles"
	%StatsLabel.text = "Niveau %d (%s)\n%s\nPièces : %d  ·  Record : %d" % [
		GameData.level, GameData.settings().name, hint, coins, best]
	_open(score, is_record)


# Apparition de l'écran et score qui défile
func _open(score: int, is_record: bool):
	%RecordLabel.visible = is_record
	modulate.a = 0.0
	show()
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.3)
	tween.tween_method(func(value): %ScoreLabel.text = str(int(value)), 0.0, float(score), 1.0)
	if %NextButton.visible:
		%NextButton.grab_focus()
	else:
		%RestartButton.grab_focus()
