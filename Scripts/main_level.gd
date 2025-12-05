extends Node2D

# Référence vers le TileMapLayer Cultivable
@onready var cultivable: TileMapLayer = $Tilemaps/Cultivable
@onready var spawn_plante_timer: Timer = $SpawnPlanteTimer

@export var spawn_plante_interval: float = 2.0

@onready var spawn_points := $Spawner.get_children()
@onready var spawn_enemy_timer: Timer = $SpawnEnemyTimer

@export var enemy_scene: PackedScene = preload("res://Scenes/enemy.tscn")

func _ready():
	spawn_plante_timer.wait_time = spawn_plante_interval
	spawn_plante_timer.timeout.connect(_on_spawn_timeout)
	spawn_plante_timer.start()
	spawn_initial_plants() # si tu veux en avoir au début
	
	spawn_enemy_timer.timeout.connect(_on_spawn_timer_timeout)

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
		

func _on_spawn_timer_timeout():
	spawn_enemy()

func spawn_enemy():
	if spawn_points.is_empty():
		return

	# Choisir un spawn au hasard
	var spawn_point = spawn_points[randi() % spawn_points.size()]

	# Instancier l’ennemi
	var enemy = enemy_scene.instantiate()
	enemy.position = spawn_point.position
	add_child(enemy)
	
