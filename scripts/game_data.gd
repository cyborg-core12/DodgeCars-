extends Node

## Données gardées entre les scènes (chargé automatiquement : "Autoload" GameData).
## Sauvegarde le meilleur score et le total de pièces dans un fichier local.

const SAVE_PATH = "user://sauvegarde.cfg"

var best_score = 0
var total_coins = 0


func _ready():
	load_data()


func load_data():
	var config = ConfigFile.new()
	if config.load(SAVE_PATH) == OK:
		best_score = config.get_value("joueur", "meilleur_score", 0)
		total_coins = config.get_value("joueur", "pieces", 0)


func save_data():
	var config = ConfigFile.new()
	config.set_value("joueur", "meilleur_score", best_score)
	config.set_value("joueur", "pieces", total_coins)
	config.save(SAVE_PATH)


# Enregistre une partie terminée. Renvoie true si c'est un nouveau record.
func submit_score(score: int, coins: int) -> bool:
	total_coins += coins
	var is_record = score > best_score
	if is_record:
		best_score = score
	save_data()
	return is_record
