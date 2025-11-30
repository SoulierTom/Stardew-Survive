extends Node2D

# Référence vers le TileMapLayer Cultivable
@onready var cultivable: TileMapLayer = $Tilemaps/Cultivable
@onready var timer_label: Label = $TimerLabel

@export var spawn_interval: float = 2.0

# Variable pour suivre le dernier temps de spawn
var last_spawn_time: float = 0.0

func _ready():
	# Exemple : spawner 3 plantes au démarrage
	spawn_initial_plants()

func _process(delta):
	# Vérifier si assez de temps s'est écoulé depuis le dernier spawn
	if timer_label.game_time - last_spawn_time >= spawn_interval:
		spawn_one_plant()
		last_spawn_time = timer_label.game_time
	

func spawn_initial_plants():
	"""Spawne quelques plantes au début du niveau"""
	if cultivable:
		cultivable.spawn_multiple_plantes(4)

func spawn_one_plant():
	"""Spawne une seule plante"""
	if cultivable:
		cultivable.spawn_plante_on_random_cultivable()
