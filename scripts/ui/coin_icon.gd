extends Control

## Petite icône de pièce dorée (à côté du compteur de pièces).


# Dessine une pièce au centre du nœud
func _draw():
	UIStyle.draw_coin(self, size / 2, min(size.x, size.y) / 2 - 2)
