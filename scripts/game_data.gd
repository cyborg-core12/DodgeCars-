extends Node

## Données gardées entre les scènes (chargé automatiquement : "Autoload" GameData).
## Contient les réglages des 3 niveaux et sauvegarde records et étoiles dans un fichier local.

const SAVE_PATH = "user://sauvegarde.cfg"

# Réglages de chaque niveau. Chaque niveau a son décor, sa longueur et sa difficulté.
const LEVELS = [
	{
		"name": "FACILE",
		"description": "La campagne · 1200 m · route calme",
		"color": Color("06d6a0"),
		"zone": 0,                    # décor (voir road.gd) : 0 = campagne
		"goal": 1200.0,               # mètres jusqu'à la ligne d'arrivée
		"start_speed": 260.0,         # vitesse au départ
		"max_speed": 420.0,           # vitesse juste avant l'arrivée
		"spawn_start": 1.7,           # secondes entre deux obstacles au départ
		"spawn_min": 1.1,             # ... et juste avant l'arrivée
		"lives": 3,
		"lane_changers": false,       # voitures qui changent de voie ?
		"double_cars": 2.0,           # dès quelle progression (0 à 1) : 2 voitures côte à côte (2 = jamais)
		"oil": false,                 # flaques d'huile ?
		"bonus_chance": 1.5,          # multiplie la chance d'avoir un bonus
		"score_multiplier": 1,
	},
	{
		"name": "NORMAL",
		"description": "La ville · 2000 m · huile et clignotants",
		"color": Color("ff6b35"),
		"zone": 1,                    # la ville
		"goal": 2000.0,
		"start_speed": 380.0,
		"max_speed": 650.0,
		"spawn_start": 1.15,
		"spawn_min": 0.7,
		"lives": 3,
		"lane_changers": true,
		"double_cars": 0.2,
		"oil": true,
		"bonus_chance": 1.0,
		"score_multiplier": 2,
	},
	{
		"name": "DIFFICILE",
		"description": "La nuit · 3000 m · 2 vies, très rapide",
		"color": Color("ef476f"),
		"zone": 3,                    # la nuit
		"goal": 3000.0,
		"start_speed": 560.0,
		"max_speed": 950.0,
		"spawn_start": 0.8,
		"spawn_min": 0.45,
		"lives": 2,
		"lane_changers": true,
		"double_cars": 0.0,
		"oil": true,
		"bonus_chance": 0.5,
		"score_multiplier": 3,
	},
]

# Voitures du garage. "handling" = vitesse pour changer de voie,
# "shield" = secondes de bouclier au départ de la partie.
const CARS = [
	{
		"name": "LA ROUGE",
		"tagline": "La voiture de départ. Équilibrée, idéale pour apprendre.",
		"texture": "res://assets/car_red_1.png",
		"color": Color("ef476f"),
		"handling": 12.0,
		"shield": 0.0,
	},
	{
		"name": "LE ROVER",
		"tagline": "Large et lent à tourner, mais blindé : bouclier de 10 s au départ.",
		"texture": "res://assets/car_rover.png",
		"color": Color("e9c46a"),
		"handling": 9.0,
		"shield": 10.0,
	},
	{
		"name": "F1 ARGENT",
		"tagline": "Fine et nerveuse. Se faufile partout.",
		"texture": "res://assets/car_f1_silver.png",
		"color": Color("ced4da"),
		"handling": 16.0,
		"shield": 0.0,
	},
	{
		"name": "F1 BLEUE",
		"tagline": "La plus maniable du garage. Pour les pilotes rapides !",
		"texture": "res://assets/car_f1_blue.png",
		"color": Color("4cc9f0"),
		"handling": 19.0,
		"shield": 0.0,
	},
	{
		"name": "LA PANTHÈRE",
		"tagline": "Sportive noire, rapide et compacte.",
		"texture": "res://assets/car_black_sport.png",
		"color": Color("b388ff"),
		"handling": 15.0,
		"shield": 0.0,
	},
]

var car = 0                   # voiture choisie dans le garage
var level = 1                 # niveau choisi dans le menu (1, 2 ou 3)
var best_scores = [0, 0, 0]   # un record par niveau
var best_stars = [0, 0, 0]    # étoiles gagnées par niveau (0 = pas encore terminé)
var total_coins = 0


# Au lancement du jeu, on charge la sauvegarde
func _ready():
	load_data()


# Réglages du niveau choisi
func settings() -> Dictionary:
	return LEVELS[level - 1]


# Réglages de la voiture choisie
func car_settings() -> Dictionary:
	return CARS[car]


# Record du niveau choisi
func best_score() -> int:
	return best_scores[level - 1]


# Lit le fichier de sauvegarde (records, étoiles, pièces, voiture choisie)
func load_data():
	var config = ConfigFile.new()
	if config.load(SAVE_PATH) == OK:
		for i in LEVELS.size():
			best_scores[i] = config.get_value("records", "niveau_%d" % (i + 1), 0)
			best_stars[i] = config.get_value("etoiles", "niveau_%d" % (i + 1), 0)
		total_coins = config.get_value("joueur", "pieces", 0)
		car = clamp(config.get_value("joueur", "voiture", 0), 0, CARS.size() - 1)


# Écrit toutes les données dans le fichier de sauvegarde
func save_data():
	var config = ConfigFile.new()
	for i in LEVELS.size():
		config.set_value("records", "niveau_%d" % (i + 1), best_scores[i])
		config.set_value("etoiles", "niveau_%d" % (i + 1), best_stars[i])
	config.set_value("joueur", "pieces", total_coins)
	config.set_value("joueur", "voiture", car)
	config.save(SAVE_PATH)


# Enregistre une partie terminée. Renvoie true si c'est un nouveau record.
# stars = 0 si le joueur a perdu, 1 à 3 s'il a passé la ligne d'arrivée.
func submit_score(score: int, coins: int, stars: int) -> bool:
	total_coins += coins
	var i = level - 1
	best_stars[i] = max(best_stars[i], stars)
	var is_record = score > best_scores[i]
	if is_record:
		best_scores[i] = score
	save_data()
	return is_record
