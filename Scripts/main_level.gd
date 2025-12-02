extends Node2D

# Référence vers le TileMapLayer Cultivable
@onready var cultivable: TileMapLayer = $Tilemaps/Cultivable
@onready var spawn_timer: Timer = $"UI/Times rate/SpawnTimer"

@export var spawn_interval: float = 2.0

func _ready():
	spawn_timer.wait_time = spawn_interval
	spawn_timer.timeout.connect(_on_spawn_timeout)
	spawn_timer.start()
	spawn_initial_plants() # si tu veux en avoir au début

func _on_spawn_timeout():
	spawn_one_plant()
	
func spawn_initial_plants():
	"""Spawne quelques plantes au début du niveau"""
	if cultivable:
		cultivable.spawn_multiple_plantes(4)

func spawn_one_plant():
	"""Spawne une seule plante"""
	if cultivable:
		cultivable.spawn_plante_on_random_cultivable()
		
