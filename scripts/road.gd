class_name Road
extends Node2D

# Route et décor qui défilent

const ZONES = [
	{
		"name": "La campagne",
		"grass": Color("5bab4f"), "grass_dark": Color("4f9a45"), "road": Color("4b4f5c"),
		"tint": Color(1, 1, 1), "decor": ["tree", "tree", "bush"],
	},
	{
		"name": "La ville",
		"grass": Color("9aa5b8"), "grass_dark": Color("8b97ab"), "road": Color("3c404b"),
		"tint": Color(1, 0.97, 0.94), "decor": ["building", "building", "lamp"],
	},
	{
		"name": "Le désert",
		"grass": Color("e8c37a"), "grass_dark": Color("dcb46a"), "road": Color("5e5650"),
		"tint": Color(1, 0.96, 0.88), "decor": ["cactus", "rock", "rock"],
	},
	{
		"name": "La nuit",
		"grass": Color("2f5a3c"), "grass_dark": Color("294f35"), "road": Color("33363f"),
		"tint": Color(0.45, 0.5, 0.78), "decor": ["lamp", "tree", "tree"], "night": true,
	},
]

const BUILDING_COLORS = [Color("e76f51"), Color("457b9d"), Color("8d6a9f"), Color("f4a261")]

var lanes = [130, 240, 350]
@export var speed = 300.0
var scroll = 0.0
var zone = 0
var decor = []
var finish_y = -9999.0

var grass: Color
var grass_dark: Color
var road_color: Color


func _ready():
	var first_zone = ZONES[0]
	grass = first_zone.grass
	grass_dark = first_zone.grass_dark
	road_color = first_zone.road
	for i in 10:
		decor.append(_new_decor(randf_range(-100, 800)))


func set_zone(index: int, instant := false):
	zone = index
	if instant:
		grass = ZONES[index].grass
		grass_dark = ZONES[index].grass_dark
		road_color = ZONES[index].road
		for i in decor.size():
			decor[i] = _new_decor(decor[i].y)


func show_finish_line():
	finish_y = -60.0


func road_left() -> float:
	return lanes[0] - 58


func road_right() -> float:
	return lanes[-1] + 58


func _new_decor(y: float) -> Dictionary:
	var on_left = randf() < 0.5
	var x
	if on_left:
		x = randf_range(4, road_left() - 30)
	else:
		x = randf_range(road_right() + 30, 476)
	return {
		"x": x,
		"y": y,
		"type": ZONES[zone].decor.pick_random(),
		"size": randf_range(0.8, 1.25),
		"color": randi() % BUILDING_COLORS.size(),
	}


func _process(delta):
	scroll += speed * delta
	if finish_y > -9999.0:
		finish_y += speed * delta

	for i in decor.size():
		decor[i].y += speed * delta
		if decor[i].y > 900:
			decor[i] = _new_decor(randf_range(-260, -80))

	var target = ZONES[zone]
	var t = clamp(delta * 1.5, 0.0, 1.0)
	grass = grass.lerp(target.grass, t)
	grass_dark = grass_dark.lerp(target.grass_dark, t)
	road_color = road_color.lerp(target.road, t)
	queue_redraw()


func _draw():
	var left = road_left()
	var right = road_right()

	draw_rect(Rect2(0, 0, 480, 800), grass)
	var y = fmod(scroll, 160.0) - 160.0
	while y < 800:
		draw_rect(Rect2(0, y, 480, 80), grass_dark)
		y += 160

	draw_rect(Rect2(left - 18, 0, right - left + 36, 800), road_color.lightened(0.25))
	draw_rect(Rect2(left, 0, right - left, 800), road_color)

	for x in lanes:
		for side in [-22, 22]:
			draw_rect(Rect2(x + side - 5, 0, 10, 800), Color(0, 0, 0, 0.08))

	y = fmod(scroll, 80.0) - 80.0
	while y < 800:
		for x in [left - 10, right]:
			draw_rect(Rect2(x, y, 10, 40), Color("e63946"))
			draw_rect(Rect2(x, y + 40, 10, 40), Color("f1f1f1"))
		y += 80

	for i in lanes.size() - 1:
		var line_x = (lanes[i] + lanes[i + 1]) / 2.0
		y = fmod(scroll, 80.0) - 80.0
		while y < 800:
			draw_rect(Rect2(line_x - 3, y + 18, 6, 44), Color(1, 1, 1, 0.85))
			y += 80

	for item in decor:
		_draw_decor(item)

	if finish_y > -9999.0:
		_draw_finish_line(left, right)


# Ligne d'arrivée
func _draw_finish_line(left: float, right: float):
	var square = 20.0
	var x = left
	var column = 0
	while x < right:
		for row in 2:
			var white = (column + row) % 2 == 0
			draw_rect(Rect2(x, finish_y + row * square, min(square, right - x), square),
				Color.WHITE if white else Color("111111"))
		x += square
		column += 1
	for pole_x in [left - 24, right + 14]:
		draw_rect(Rect2(pole_x + 4, finish_y - 50, 10, 100), Color(0, 0, 0, 0.3))
		draw_rect(Rect2(pole_x, finish_y - 56, 10, 100), Color("dee2e6"))
	var banner = Rect2(left - 20, finish_y - 64, right - left + 40, 30)
	draw_rect(banner, UIStyle.RED)
	draw_string(UIStyle.font(), Vector2(banner.position.x, banner.position.y + 24), "ARRIVÉE",
		HORIZONTAL_ALIGNMENT_CENTER, banner.size.x, 22, Color.WHITE)


func _draw_decor(item: Dictionary):
	var p = Vector2(item.x, item.y)
	var s = item.size
	var shadow = Color(0, 0, 0, 0.22)
	match item.type:
		"tree":
			draw_circle(p + Vector2(8, 10), 26 * s, shadow)
			draw_circle(p, 26 * s, Color("2d6a4f"))
			draw_circle(p + Vector2(-6, -6) * s, 19 * s, Color("40916c"))
			draw_circle(p + Vector2(-10, -10) * s, 9 * s, Color("74c69d"))
		"bush":
			var parts = [Vector2(-10, 0), Vector2(10, 2), Vector2(0, -9)]
			for o in parts:
				draw_circle(p + o * s + Vector2(5, 6), 12 * s, shadow)
			for o in parts:
				draw_circle(p + o * s, 12 * s, Color("52b788"))
		"building":
			var color = BUILDING_COLORS[item.color]
			var size = Vector2(64, 96) * s
			var rect = Rect2(p - size / 2, size)
			draw_rect(Rect2(rect.position + Vector2(10, 12), size), Color(0, 0, 0, 0.3))
			draw_rect(rect, color.darkened(0.2))
			draw_rect(rect.grow(-5), color)
			draw_rect(Rect2(rect.position + Vector2(12, 14), Vector2(16, 12)), Color("adb5bd"))
			draw_rect(Rect2(rect.position + Vector2(12, 34), Vector2(16, 12)), Color("adb5bd"))
			draw_circle(rect.get_center() + Vector2(8, 18) * s, 8 * s, Color(1, 1, 1, 0.35))
		"lamp":
			draw_circle(p, 46, Color(1, 0.85, 0.4, 0.12))
			draw_circle(p, 22, Color(1, 0.85, 0.4, 0.22))
			draw_circle(p + Vector2(4, 5), 7, Color(0, 0, 0, 0.3))
			draw_circle(p, 7, Color("495057"))
			draw_circle(p, 4, Color("fff3b0"))
		"cactus":
			draw_circle(p + Vector2(6, 8), 16 * s, shadow)
			draw_circle(p, 16 * s, Color("2a9d8f"))
			for i in 8:
				var dir = Vector2.RIGHT.rotated(i * TAU / 8.0)
				draw_line(p + dir * 10 * s, p + dir * 20 * s, Color("e9f5db"), 2)
			draw_circle(p, 8 * s, Color("52b788"))
			draw_circle(p, 3 * s, Color("ff70a6"))
		"rock":
			draw_circle(p + Vector2(6, 7), 14 * s, shadow)
			draw_circle(p, 14 * s, Color("a68a64"))
			draw_circle(p + Vector2(-4, -4) * s, 9 * s, Color("c2a878"))
