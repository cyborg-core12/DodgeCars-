extends Control

# Icône de pièce

func _draw():
	UIStyle.draw_coin(self, size / 2, min(size.x, size.y) / 2 - 2)
