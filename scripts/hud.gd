extends CanvasLayer

## Interface du jeu (scène hud.tscn) : score, vies, pièces, progression,
## bonus actifs et messages. Contient aussi le menu pause et l'écran de fin.
## Tous les éléments sont des nœuds de la scène : ce script ne fait que les mettre à jour.

signal restart_requested
signal menu_requested
signal next_requested

var playing = true     # false quand la partie est finie (plus de pause possible)
var level_text = ""    # "NIVEAU 1 · FACILE · LA CAMPAGNE"

var message_tween: Tween
var combo_tween: Tween


# Relie le menu pause et l'écran de fin, et fait disparaître l'aide au bout de 5 s
func _ready():
	%PauseMenu.resume_pressed.connect(toggle_pause)
	%PauseMenu.menu_pressed.connect(_go_menu)
	%EndScreen.next_pressed.connect(_go_next)
	%EndScreen.restart_pressed.connect(_restart)
	%EndScreen.menu_pressed.connect(_go_menu)

	var tween = create_tween()
	tween.tween_interval(5.0)
	tween.tween_property(%HintLabel, "modulate:a", 0.0, 1.0)


# ---------- MISE À JOUR (appelée par main.gd) ----------

# Nombre de cœurs selon le niveau (2 ou 3)
func set_max_lives(value: int):
	%Hearts.set_max_lives(value)
	%Hearts.set_lives(value)


# Met à jour tous les compteurs à chaque image
func update_stats(score, best, coins, lives, distance, goal, shield, magnet, slip):
	%ScoreLabel.text = str(score)
	%BestLabel.text = "RECORD %d" % max(best, score)
	%CoinsLabel.text = str(coins)
	%Hearts.set_lives(lives)
	# Barre de progression vers la ligne d'arrivée
	%ProgressFill.size.x = %ProgressBack.size.x * clamp(distance / goal, 0.0, 1.0)
	%LevelLabel.text = "%s   ·   %d / %d m" % [level_text, min(distance, goal), goal]
	%Powerups.update_times(shield, magnet)
	%WarningLabel.visible = slip > 0
	if %WarningLabel.visible:
		%WarningLabel.modulate.a = 0.5 + 0.5 * sin(Time.get_ticks_msec() / 80.0)


# Affiche le nom du niveau et colore la barre de progression
func set_level(number: int, level_name: String, zone_name: String, color: Color):
	level_text = "NIVEAU %d  ·  %s  ·  %s" % [number, level_name, zone_name.to_upper()]
	%LevelLabel.text = level_text
	%ProgressFill.self_modulate = color


# Affiche un grand message au centre qui "pop" puis disparaît
func show_message(text: String):
	%MessageLabel.text = text
	%MessageLabel.show()
	%MessageLabel.scale = Vector2(0.4, 0.4)
	%MessageLabel.modulate.a = 1.0
	if message_tween:
		message_tween.kill()
	message_tween = create_tween()
	message_tween.tween_property(%MessageLabel, "scale", Vector2.ONE, 0.35) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	message_tween.tween_interval(1.6)
	message_tween.tween_property(%MessageLabel, "modulate:a", 0.0, 0.4)
	message_tween.tween_callback(%MessageLabel.hide)


# Affiche "COMBO xN !" quand on enchaîne les pièces
func show_combo(combo: int):
	%ComboLabel.text = "COMBO x%d !" % combo
	%ComboLabel.modulate.a = 1.0
	%ComboLabel.scale = Vector2(1.5, 1.5)
	if combo_tween:
		combo_tween.kill()
	combo_tween = create_tween()
	combo_tween.tween_property(%ComboLabel, "scale", Vector2.ONE, 0.2)
	combo_tween.tween_interval(0.6)
	combo_tween.tween_property(%ComboLabel, "modulate:a", 0.0, 0.3)


# Fait flasher l'écran d'une couleur (rouge quand on est touché)
func flash_screen(color: Color):
	%Flash.color = Color(color, 0.45)
	var tween = create_tween()
	tween.tween_property(%Flash, "color:a", 0.0, 0.4)


# Écran de défaite (voir end_screen.gd)
func show_game_over(score: int, distance: int, goal: int, coins: int, best: int, is_record: bool):
	playing = false
	%EndScreen.show_game_over(score, distance, goal, coins, best, is_record)


# Écran de victoire (voir end_screen.gd)
func show_victory(score: int, stars: int, coins: int, best: int, is_record: bool, has_next: bool):
	playing = false
	%EndScreen.show_victory(score, stars, coins, best, is_record, has_next)


# ---------- PAUSE ET BOUTONS ----------

# P ou Échap : pause pendant la partie. Échap sur l'écran de fin : retour au menu.
func _unhandled_input(event):
	if not (event is InputEventKey and event.pressed and not event.echo):
		return
	if playing and (event.keycode == KEY_P or event.keycode == KEY_ESCAPE):
		toggle_pause()
		get_viewport().set_input_as_handled()
	elif %EndScreen.visible and event.keycode == KEY_ESCAPE:
		_go_menu()


# Met le jeu en pause ou le relance
func toggle_pause():
	if not playing:
		return
	var paused = not get_tree().paused
	get_tree().paused = paused
	if paused:
		%PauseMenu.open()
	else:
		%PauseMenu.hide()


# Bouton Rejouer : enlève la pause et prévient main.gd
func _restart():
	get_tree().paused = false
	restart_requested.emit()


# Bouton Niveau suivant : prévient main.gd
func _go_next():
	get_tree().paused = false
	next_requested.emit()


# Bouton Menu : enlève la pause et prévient main.gd
func _go_menu():
	get_tree().paused = false
	menu_requested.emit()
