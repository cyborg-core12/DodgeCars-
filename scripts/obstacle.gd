class_name Obstacle
extends Area2D

## Script de base pour tout ce qui descend la route :
## voitures, cônes, flaques d'huile, pièces et bonus.
## Les autres scripts en héritent avec "extends Obstacle".

# Vitesse de la route, partagée par tous les obstacles (main.gd la met à jour)
static var world_speed = 320.0

# Ce que représente l'objet : "danger", "oil", "coin", "shield", "magnet" ou "heart"
var kind = "danger"

# Pour qu'un objet descende un peu moins vite que la route (1.0 = même vitesse)
var speed_factor = 1.0


# Chaque obstacle s'ajoute au groupe "obstacles"
func _ready():
	add_to_group("obstacles")


# À chaque image : l'objet descend avec la route
func _process(delta):
	position.y += world_speed * speed_factor * delta
	# Supprime l'objet quand il est sorti de l'écran
	if position.y > 1000:
		queue_free()
