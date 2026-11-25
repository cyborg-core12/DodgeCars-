extends Node2D

# Voiture qui roule dans le menu

const CAR_HEIGHT = 135.0


func show_car(texture: Texture2D):
	$Sprite2D.texture = texture
	var s = CAR_HEIGHT / texture.get_height()
	$Sprite2D.scale = Vector2(s, s)
	queue_redraw()


func _draw():
	if $Sprite2D.texture == null:
		return
	var car_size = $Sprite2D.texture.get_size() * $Sprite2D.scale
	draw_rect(Rect2(-car_size / 2 + Vector2(6, 8), car_size), Color(0, 0, 0, 0.3))
