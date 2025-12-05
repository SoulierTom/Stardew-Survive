extends Node2D

# Référence au Sprite2D
@onready var sprite: Sprite2D = $Sprite2D

# Texture du tileset contenant tous les stades de la plante
@export var plant_tileset: Texture2D

# Paramètres pour découper le tileset
@export var tile_size: Vector2i = Vector2i(16, 16)
@export var hframes: int = 6
@export var vframes: int = 1

# Stades de croissance (indices des frames dans le tileset)
@export var growth_stages: Array[int] = [0, 1, 2, 3, 4, 5]

# Distance d'interaction avec le joueur
@export var interaction_range: float = 25.0

# Temps entre chaque stade de croissance automatique (en secondes)
@export var growth_interval: float = 3.0

# Stade actuel
var current_stage: int = 0

# État de la plante
var is_growing: bool = false  # Est-ce que la croissance automatique est activée ?
var growth_timer: float = 0.0

# Référence au cultivable (pour libérer la case)
var cultivable_tilemap: TileMapLayer = null
var cell_position: Vector2i = Vector2i.ZERO

# Référence au joueur
var player: CharacterBody2D = null

func _ready():
	add_to_group("plants")
	setup_sprite()
	set_stage(0)
	find_cultivable_reference()
	find_player()

func find_player():
	"""Trouve le joueur dans la scène"""
	player = get_tree().get_first_node_in_group("player")
	if not player:
		player = get_node_or_null("/root/MainLevel/Player")

func find_cultivable_reference():
	"""Trouve le TileMapLayer cultivable dans la scène"""
	var parent = get_parent()
	while parent:
		if parent.name == "MainLevel" or parent is Node2D:
			var tilemaps = parent.get_node_or_null("Tilemaps")
			if tilemaps:
				cultivable_tilemap = tilemaps.get_node_or_null("Cultivable")
				if cultivable_tilemap:
					cell_position = cultivable_tilemap.local_to_map(global_position)
					break
		parent = parent.get_parent()

func setup_sprite():
	"""Configure le sprite avec le tileset"""
	if sprite and plant_tileset:
		sprite.texture = plant_tileset
		sprite.hframes = hframes
		sprite.vframes = vframes

func _process(delta):
	# Vérifier l'interaction du joueur (seulement au stade 0)
	if current_stage == 0:
		if Input.is_action_just_pressed("Interact_Main"):
			if is_player_nearby():
				start_growing()
	if current_stage == 5:
		if Input.is_action_just_pressed("Interact_Main"):
			if is_player_nearby():
				harvest()
	
	# Croissance automatique si activée
	if is_growing:
		growth_timer += delta
		
		if growth_timer >= growth_interval:
			growth_timer = 0.0
			grow_next_stage()

func is_player_nearby() -> bool:
	"""Vérifie si le joueur est à proximité de la plante"""
	if not player or not is_instance_valid(player):
		find_player()
		if not player:
			return false
	
	var distance = global_position.distance_to(player.global_position)
	return distance <= interaction_range

func start_growing():
	"""Démarre la croissance de la plante (passage du stade 0 au 1)"""
	if current_stage == 0:
		print("Plante activée ! Début de la croissance...")
		grow_next_stage()
		is_growing = true
		growth_timer = 0.0

func grow_next_stage():
	"""Fait passer la plante au stade suivant"""
	if current_stage < growth_stages.size() - 1:
		current_stage += 1
		set_stage(current_stage)
		print("Plante au stade : ", current_stage)
		
		# Effet visuel
		play_grow_effect()
	else:
		# Plante complètement mature, arrêter la croissance
		is_growing = false
		print("Plante complètement mature !")
		on_fully_grown()

func set_stage(stage: int):
	"""Définit le stade de croissance de la plante"""
	if stage >= 0 and stage < growth_stages.size():
		current_stage = stage
		if sprite:
			sprite.frame = growth_stages[stage]

func play_grow_effect():
	"""Effet visuel de croissance"""
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_ELASTIC)
	tween.set_ease(Tween.EASE_OUT)
	
	# Effet de "pop"
	tween.tween_property(self, "scale", Vector2(1.3, 1.3), 0.2)
	tween.tween_property(self, "scale", Vector2.ONE, 0.3)

func on_fully_grown():
	"""Appelé quand la plante atteint le stade final"""
	print("La plante peut être récoltée !")
	# Vous pouvez ajouter un indicateur visuel ici

func harvest():
	"Augmente le score"
	game_manager.add_score()
	"""Récolte la plante"""
	destroy()

func destroy():
	"""Détruit proprement la plante en libérant sa case"""
	if cultivable_tilemap and cultivable_tilemap.has_method("free_cell"):
		cultivable_tilemap.free_cell(cell_position)
	queue_free()

func get_current_stage() -> int:
	"""Retourne le stade actuel"""
	return current_stage

func is_fully_grown() -> bool:
	"""Vérifie si la plante est complètement mature"""
	return current_stage >= growth_stages.size() - 1

func get_growth_progress() -> float:
	"""Retourne le pourcentage de croissance (0.0 à 1.0)"""
	if not is_growing or current_stage >= growth_stages.size() - 1:
		return 1.0
	return growth_timer / growth_interval
