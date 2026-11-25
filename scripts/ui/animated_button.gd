extends Button

## Bouton qui grossit un peu quand on le survole avec la souris
## ou quand on le choisit au clavier. Utilisé par tous les boutons du jeu.

# Taille du bouton quand il est survolé (1.0 = taille normale)
@export var hover_scale = 1.06


# Relie les signaux de survol et de sélection à l'animation
func _ready():
	resized.connect(_center_pivot)
	_center_pivot()
	mouse_entered.connect(_bounce.bind(hover_scale))
	mouse_exited.connect(_bounce.bind(1.0))
	focus_entered.connect(_bounce.bind(hover_scale))
	focus_exited.connect(_bounce.bind(1.0))


# Le bouton grossit depuis son centre (et pas depuis son coin en haut à gauche)
func _center_pivot():
	pivot_offset = size / 2


# Animation douce vers la taille voulue
func _bounce(target: float):
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2.ONE * target, 0.12) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
