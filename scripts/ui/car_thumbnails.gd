extends Control

## Rangée de miniatures de toutes les voitures du garage (cliquables).

signal car_clicked(index)

const THUMB_WIDTH = 80.0
const THUMB_GAP = 8.0

var textures = []
var selected = 0   # voiture affichée dans la vitrine
var equipped = 0   # voiture choisie par le joueur


# Charge l'image de chaque voiture
func _ready():
	for settings in GameData.CARS:
		textures.append(load(settings.texture))


# Met à jour la voiture affichée et la voiture équipée
func set_selection(new_selected: int, new_equipped: int):
	selected = new_selected
	equipped = new_equipped
	queue_redraw()


# Dessine une case par voiture, avec la voiture tournée sur le côté
func _draw():
	for i in textures.size():
		var slot = Rect2(i * (THUMB_WIDTH + THUMB_GAP), 0, THUMB_WIDTH, size.y)
		var box = UIStyle.make_box(Color(1, 1, 1, 0.12) if i == selected else Color(0, 0, 0, 0.35), 12)
		if i == selected:
			box.border_color = GameData.CARS[i].color
			box.set_border_width_all(3)
		draw_style_box(box, slot)

		var texture = textures[i]
		var car_size = texture.get_size() * (52.0 / texture.get_height())
		draw_set_transform(slot.get_center(), PI / 2, Vector2.ONE)
		draw_texture_rect(texture, Rect2(-car_size / 2, car_size), false)
		draw_set_transform(Vector2.ZERO, 0, Vector2.ONE)

		# Point vert sur la voiture équipée
		if i == equipped:
			draw_circle(slot.position + Vector2(THUMB_WIDTH - 10, 10), 6, UIStyle.GREEN)


# Clic sur une case : on prévient le garage
func _gui_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var clicked = int(event.position.x / (THUMB_WIDTH + THUMB_GAP))
		if clicked >= 0 and clicked < textures.size():
			car_clicked.emit(clicked)
