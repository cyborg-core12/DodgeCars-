extends Obstacle

## Objet à ramasser : pièce, bouclier, aimant ou cœur (+1 vie).
## main.gd choisit le type en changeant "kind" avant de l'ajouter à la scène.

var time = randf() * 10.0
var attract_speed = 0.0


func _process(delta):
	time += delta
	queue_redraw()

	# Si l'aimant est actif, les pièces proches volent vers le joueur
	var player = get_tree().get_first_node_in_group("player")
	if kind == "coin" and player and player.magnet_time > 0 \
			and global_position.distance_to(player.global_position) < 320:
		attract_speed += 2000 * delta
		global_position = global_position.move_toward(player.global_position, attract_speed * delta)
	else:
		super(delta)


func _draw():
	match kind:
		"coin":
			_draw_spinning_coin()
		"shield":
			_draw_bubble(UIStyle.BLUE)
			draw_colored_polygon(PackedVector2Array([
				Vector2(0, -12), Vector2(11, -7), Vector2(9, 5),
				Vector2(0, 13), Vector2(-9, 5), Vector2(-11, -7),
			]), Color.WHITE)
		"magnet":
			_draw_bubble(UIStyle.RED)
			draw_arc(Vector2(0, 0), 9, 0, PI, 16, Color("e63946"), 7)
			draw_rect(Rect2(-12.5, -10, 7, 10), Color("e63946"))
			draw_rect(Rect2(5.5, -10, 7, 10), Color("e63946"))
			draw_rect(Rect2(-12.5, -14, 7, 5), Color("dee2e6"))
			draw_rect(Rect2(5.5, -14, 7, 5), Color("dee2e6"))
		"heart":
			_draw_bubble(UIStyle.GREEN)
			UIStyle.draw_heart(self, Vector2(0, -2), 24, UIStyle.RED)


# La pièce "tourne" : on l'écrase horizontalement avec un cosinus
func _draw_spinning_coin():
	draw_circle(Vector2(4, 6), 14, Color(0, 0, 0, 0.25))
	var squash = max(abs(cos(time * 4.0)), 0.15)
	draw_set_transform(Vector2.ZERO, 0, Vector2(squash, 1))
	UIStyle.draw_coin(self, Vector2.ZERO, 15)
	draw_set_transform(Vector2.ZERO, 0, Vector2.ONE)


# Bulle lumineuse qui "respire" autour des bonus
func _draw_bubble(color: Color):
	var pulse = sin(time * 5.0) * 3.0
	draw_circle(Vector2(4, 6), 21, Color(0, 0, 0, 0.25))
	draw_circle(Vector2.ZERO, 27 + pulse, Color(color, 0.25))
	draw_circle(Vector2.ZERO, 21, UIStyle.DARK)
	draw_arc(Vector2.ZERO, 21, 0, TAU, 32, color, 3)
