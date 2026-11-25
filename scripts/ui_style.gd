class_name UIStyle
extends RefCounted

## Couleurs du jeu et petits dessins réutilisés (cœur, pièce, étoile).
## Le style des boutons, textes et panneaux est dans le thème : theme/game_theme.tres
## Toutes les fonctions sont "static" : on les appelle avec UIStyle.nom_fonction().

# ---------- PALETTE DE COULEURS ----------
const YELLOW = Color("ffd23f")
const ORANGE = Color("ff6b35")
const RED = Color("ef476f")
const BLUE = Color("4cc9f0")
const PURPLE = Color("b388ff")
const GREEN = Color("06d6a0")
const DARK = Color("14182b")
const GREY = Color("3d4566")
const PANEL = Color(0.08, 0.09, 0.17, 0.88)

const THEME = preload("res://theme/game_theme.tres")


# Police du jeu (celle du thème), pour les textes dessinés avec draw_string()
static func font() -> Font:
	return THEME.default_font


# Rectangle arrondi d'une couleur, pour dessiner des barres et des pastilles
static func make_box(color: Color, radius := 14) -> StyleBoxFlat:
	var box = StyleBoxFlat.new()
	box.bg_color = color
	box.set_corner_radius_all(radius)
	return box


# Dessine un cœur : deux ronds en haut et un triangle en bas
static func draw_heart(canvas: CanvasItem, center: Vector2, heart_size: float, color: Color) -> void:
	var r = heart_size * 0.3
	canvas.draw_circle(center + Vector2(-r, -r * 0.3), r, color)
	canvas.draw_circle(center + Vector2(r, -r * 0.3), r, color)
	canvas.draw_colored_polygon(PackedVector2Array([
		center + Vector2(-2 * r, 0),
		center + Vector2(2 * r, 0),
		center + Vector2(0, heart_size * 0.55),
	]), color)


# Dessine une pièce dorée avec un petit reflet
static func draw_coin(canvas: CanvasItem, center: Vector2, radius: float) -> void:
	canvas.draw_circle(center, radius, Color("c98a0b"))
	canvas.draw_circle(center, radius * 0.75, YELLOW)
	canvas.draw_circle(center + Vector2(-radius, -radius) * 0.25, radius * 0.22, Color(1, 1, 1, 0.7))


# Dessine une étoile à 5 branches (10 points : pointes et creux en alternance)
static func draw_star(canvas: CanvasItem, center: Vector2, radius: float, color: Color) -> void:
	var points = PackedVector2Array()
	for i in 10:
		var r = radius if i % 2 == 0 else radius * 0.45
		var angle = -PI / 2 + i * PI / 5
		points.append(center + Vector2(cos(angle), sin(angle)) * r)
	canvas.draw_colored_polygon(points, color)
