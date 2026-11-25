extends CPUParticles2D

## Petite explosion de particules (pièce ramassée, choc, feux d'artifice...).
## Les réglages de base sont dans la scène burst.tscn, ce script change
## seulement la couleur, le nombre et la force des particules.


# Lance l'explosion à la position donnée, puis supprime le nœud
func start(pos: Vector2, new_color: Color, particle_count: int, power: float, particle_size: float):
	position = pos
	color = new_color
	amount = particle_count
	initial_velocity_min = power * 0.4
	initial_velocity_max = power
	scale_amount_min = particle_size * 0.5
	scale_amount_max = particle_size
	emitting = true
	finished.connect(queue_free)
