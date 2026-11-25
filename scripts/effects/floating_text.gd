extends Label

## Texte qui monte et disparaît (+10, -1 VIE, BOUCLIER !...).
## main.gd crée une copie de la scène floating_text.tscn à chaque fois.


# Affiche le texte à la position donnée, puis lance l'animation
func start(pos: Vector2, new_text: String, color: Color):
	text = new_text
	position = pos - size / 2
	add_theme_color_override("font_color", color)
	var tween = create_tween().set_parallel(true)
	tween.tween_property(self, "position:y", position.y - 70, 0.8) \
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "modulate:a", 0.0, 0.5).set_delay(0.3)
	tween.chain().tween_callback(queue_free)
