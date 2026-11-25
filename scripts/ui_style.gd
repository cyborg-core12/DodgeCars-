class_name UIStyle
extends RefCounted

## Couleurs, police et styles partagés par tous les écrans du jeu.
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

static var _font: Font = null


# Police épaisse style "arcade" (polices installées sur Windows)
static func font() -> Font:
	if _font == null:
		var system_font = SystemFont.new()
		system_font.font_names = PackedStringArray(["Segoe UI Black", "Arial Black", "Impact"])
		system_font.font_weight = 900
		_font = system_font
	return _font


# ---------- TEXTES ----------

static func style_label(label: Label, font_size: int, color: Color, outline := 8) -> void:
	label.add_theme_font_override("font", font())
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_outline_color", DARK)
	label.add_theme_constant_override("outline_size", outline)
	label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.45))
	label.add_theme_constant_override("shadow_offset_x", 0)
	label.add_theme_constant_override("shadow_offset_y", 4)


static func make_label(text: String, font_size: int, color: Color, pos: Vector2, label_size: Vector2,
		align := HORIZONTAL_ALIGNMENT_CENTER) -> Label:
	var label = Label.new()
	label.text = text
	label.position = pos
	label.size = label_size
	label.horizontal_alignment = align
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	style_label(label, font_size, color)
	return label


# ---------- BOÎTES ET PANNEAUX ----------

static func make_box(color: Color, radius := 14, margin := 12) -> StyleBoxFlat:
	var box = StyleBoxFlat.new()
	box.bg_color = color
	box.set_corner_radius_all(radius)
	box.set_content_margin_all(margin)
	return box


# Panneau sombre arrondi avec une ombre (barre du haut, menus...)
static func make_panel(pos: Vector2, panel_size: Vector2) -> Panel:
	var panel = Panel.new()
	panel.position = pos
	panel.size = panel_size
	var box = make_box(PANEL, 22)
	box.border_color = Color(1, 1, 1, 0.12)
	box.set_border_width_all(2)
	box.shadow_color = Color(0, 0, 0, 0.4)
	box.shadow_size = 18
	box.shadow_offset = Vector2(0, 8)
	panel.add_theme_stylebox_override("panel", box)
	return panel


# ---------- BOUTONS ----------

# Bouton coloré avec un effet "3D" (bord plus foncé en bas) et une animation au survol
static func style_button(button: Button, text: String, color: Color, font_size := 26) -> void:
	button.text = text
	button.custom_minimum_size = Vector2(0, 64)
	button.add_theme_font_override("font", font())
	button.add_theme_font_size_override("font_size", font_size)
	for state in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color", "font_hover_pressed_color"]:
		button.add_theme_color_override(state, Color.WHITE)
	button.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.35))
	button.add_theme_constant_override("outline_size", 6)
	button.add_theme_stylebox_override("normal", _button_box(color, 6))
	button.add_theme_stylebox_override("hover", _button_box(color.lightened(0.15), 6))
	button.add_theme_stylebox_override("pressed", _button_box(color.darkened(0.1), 2))
	button.add_theme_stylebox_override("focus", _focus_box())

	# Le bouton grossit un peu quand la souris passe dessus ou quand il est choisi au clavier
	button.resized.connect(func(): button.pivot_offset = button.size / 2)
	button.mouse_entered.connect(func(): _bounce(button, 1.06))
	button.mouse_exited.connect(func(): _bounce(button, 1.0))
	button.focus_entered.connect(func(): _bounce(button, 1.06))
	button.focus_exited.connect(func(): _bounce(button, 1.0))


static func _button_box(color: Color, depth: int) -> StyleBoxFlat:
	var box = make_box(color, 16)
	box.border_color = color.darkened(0.35)
	box.border_width_bottom = depth
	box.content_margin_top = 12 + (6 - depth)
	return box


static func _focus_box() -> StyleBoxFlat:
	var box = StyleBoxFlat.new()
	box.draw_center = false
	box.set_corner_radius_all(18)
	box.set_border_width_all(3)
	box.border_color = Color.WHITE
	box.set_expand_margin_all(4)
	return box


static func _bounce(node: Control, target: float) -> void:
	if not node.is_inside_tree():
		return
	var tween = node.create_tween()
	tween.tween_property(node, "scale", Vector2.ONE * target, 0.12) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


# ---------- PETITS DESSINS RÉUTILISÉS ----------

static func draw_heart(canvas: CanvasItem, center: Vector2, heart_size: float, color: Color) -> void:
	var r = heart_size * 0.3
	canvas.draw_circle(center + Vector2(-r, -r * 0.3), r, color)
	canvas.draw_circle(center + Vector2(r, -r * 0.3), r, color)
	canvas.draw_colored_polygon(PackedVector2Array([
		center + Vector2(-2 * r, 0),
		center + Vector2(2 * r, 0),
		center + Vector2(0, heart_size * 0.55),
	]), color)


static func draw_coin(canvas: CanvasItem, center: Vector2, radius: float) -> void:
	canvas.draw_circle(center, radius, Color("c98a0b"))
	canvas.draw_circle(center, radius * 0.75, YELLOW)
	canvas.draw_circle(center + Vector2(-radius, -radius) * 0.25, radius * 0.22, Color(1, 1, 1, 0.7))
