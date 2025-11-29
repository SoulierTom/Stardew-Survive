extends Node2D

# Référence au Sprite2D
@onready var sprite: Sprite2D = $Sprite2D

# Texture du tileset contenant tous les stades de la plante
@export var plant_tileset: Texture2D

# Paramètres pour découper le tileset
@export var tile_size: Vector2i = Vector2i(16, 16)  # Taille d'une tuile
@export var hframes: int = 8  # Nombre de colonnes dans le tileset
@export var vframes: int = 1  # Nombre de lignes dans le tileset

# Stades de croissance (indices des frames dans le tileset)
@export var growth_stages: Array[int] = [0, 1, 2, 3, 4, 5]  # Indices des sprites

# Stade actuel
var current_stage: int = 0

func _ready():
	setup_sprite()
	set_stage(1)  # Commencer au stade 0 (graine)

func setup_sprite():
	"""Configure le sprite avec le tileset"""
	if sprite and plant_tileset:
		sprite.texture = plant_tileset
		sprite.hframes = hframes
		sprite.vframes = vframes

func _input(event):
	# Appuyer sur Accept (Espace/Enter) pour passer au stade suivant
	if event.is_action_pressed("Interact"):
		if is_mouse_over():
			grow_next_stage()

func is_mouse_over() -> bool:
	"""Vérifie si la souris est au-dessus de la plante"""
	var mouse_pos = get_global_mouse_position()
	var distance = global_position.distance_to(mouse_pos)
	return distance < 32  # Rayon de détection en pixels

func grow_next_stage():
	"""Fait passer la plante au stade suivant"""
	if current_stage < growth_stages.size() - 1:
		current_stage += 1
		set_stage(current_stage)
		print("Plante au stade : ", current_stage)
	else:
		print("Plante complètement mature !")
		on_fully_grown()

func set_stage(stage: int):
	"""Définit le stade de croissance de la plante"""
	if stage >= 0 and stage < growth_stages.size():
		current_stage = stage
		if sprite:
			sprite.frame = growth_stages[stage]

func on_fully_grown():
	"""Appelé quand la plante atteint le stade final"""
	# Vous pouvez ajouter ici du code pour la récolte, etc.
	print("La plante peut être récoltée !")

func harvest():
	"""Récolte la plante"""
	# Animation ou effet de récolte ici
	queue_free()  # Supprime la plante

func get_current_stage() -> int:
	"""Retourne le stade actuel"""
	return current_stage

func is_fully_grown() -> bool:
	"""Vérifie si la plante est complètement mature"""
	return current_stage >= growth_stages.size() - 1
