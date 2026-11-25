extends Control

## Menu pause (scène pause_menu.tscn).
## Le HUD l'affiche quand on appuie sur P ou Échap.

signal resume_pressed
signal menu_pressed


# Relie les boutons de la scène aux signaux du menu
func _ready():
	%ResumeButton.pressed.connect(resume_pressed.emit)
	%MenuButton.pressed.connect(menu_pressed.emit)
	hide()


# Affiche le menu et sélectionne "Reprendre" (pour pouvoir jouer au clavier)
func open():
	show()
	%ResumeButton.grab_focus()
