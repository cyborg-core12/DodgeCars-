extends Button

# Bouton qui grossit au survol

@export var hover_scale = 1.06


func _ready():
	resized.connect(_center_pivot)
	_center_pivot()
	mouse_entered.connect(_bounce.bind(hover_scale))
	mouse_exited.connect(_bounce.bind(1.0))
	focus_entered.connect(_bounce.bind(hover_scale))
	focus_exited.connect(_bounce.bind(1.0))


func _center_pivot():
	pivot_offset = size / 2


func _bounce(target: float):
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2.ONE * target, 0.12) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
