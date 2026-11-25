extends Control

# Menu pause

signal resume_pressed
signal menu_pressed


func _ready():
	%ResumeButton.pressed.connect(resume_pressed.emit)
	%MenuButton.pressed.connect(menu_pressed.emit)
	hide()


func open():
	show()
	%ResumeButton.grab_focus()
