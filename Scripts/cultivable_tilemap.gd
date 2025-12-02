extends TileMapLayer

# Référence vers la scène de plante
@export var plante_scene: PackedScene

# Nœud conteneur pour les plantes (optionnel)
var plants_container: Node2D

# Dictionnaire pour suivre les cases occupées
# Clé = coordonnées de cellule (Vector2i), Valeur = référence à la plante
var occupied_cells: Dictionary = {}

func _ready():
	# Récupérer ou créer le conteneur de plantes
	plants_container = get_node_or_null("../Plants")
	if plants_container == null:
		# Utiliser le parent si pas de conteneur spécifique
		plants_container = get_parent()

func get_all_cultivable_positions() -> Array[Vector2]:
	"""Récupère toutes les positions des tuiles cultivables"""
	var cultivable_positions: Array[Vector2] = []
	
	# Parcourir toutes les cellules utilisées dans ce TileMapLayer
	var used_cells = get_used_cells()
	
	for cell_coords in used_cells:
		# Convertir les coordonnées de cellule en position monde
		var world_pos = map_to_local(cell_coords)
		cultivable_positions.append(world_pos)
	
	return cultivable_positions

func get_available_cells() -> Array[Vector2i]:
	"""Récupère uniquement les cellules cultivables non occupées"""
	var all_cells = get_used_cells()
	var available: Array[Vector2i] = []
	
	for cell in all_cells:
		if not is_cell_occupied(cell):
			available.append(cell)
	
	return available

func is_cell_occupied(cell_coords: Vector2i) -> bool:
	"""Vérifie si une cellule est déjà occupée par une plante"""
	return occupied_cells.has(cell_coords)

func mark_cell_occupied(cell_coords: Vector2i, plante: Node2D):
	"""Marque une cellule comme occupée"""
	occupied_cells[cell_coords] = plante
	
	# Connecter le signal de suppression pour libérer la case
	if plante and not plante.tree_exiting.is_connected(_on_plante_removed):
		plante.tree_exiting.connect(_on_plante_removed.bind(cell_coords))

func free_cell(cell_coords: Vector2i):
	"""Libère une cellule (la rend disponible)"""
	occupied_cells.erase(cell_coords)

func _on_plante_removed(cell_coords: Vector2i):
	"""Appelé quand une plante est supprimée pour libérer la case"""
	free_cell(cell_coords)

func spawn_plante_on_random_cultivable() -> Node2D:
	"""Spawne une plante sur un bloc cultivable aléatoire non occupé"""
	if plante_scene == null:
		push_error("La scène de plante n'est pas assignée dans Cultivable !")
		return null
	
	# Récupérer uniquement les cellules disponibles
	var available_cells = get_available_cells()
	
	if available_cells.is_empty():
		push_warning("Aucune case cultivable disponible (toutes occupées) !")
		return null
	
	# Choisir une cellule aléatoire parmi les disponibles
	var random_index = randi() % available_cells.size()
	var cell_coords = available_cells[random_index]
	
	# Spawner à cette cellule
	return spawn_plante_at_cell(cell_coords)

func spawn_plante_at_cell(cell_coords: Vector2i) -> Node2D:
	"""Spawne une plante à des coordonnées de cellule spécifiques"""
	print("Tentative spawn à cell: ", cell_coords)
	
	if plante_scene == null:
		push_error("La scène de plante n'est pas assignée !")
		return null
	
	# Vérifier que cette cellule existe
	var tile_data = get_cell_tile_data(cell_coords)
	print("Tile data: ", tile_data)
	
	if tile_data == null:
		push_warning("Aucune tuile à ces coordonnées : " + str(cell_coords))
		# On essaie quand même de spawner car la cellule existe dans used_cells
		print("Spawn quand même car cellule valide dans used_cells")
	
	# Vérifier si la cellule est déjà occupée
	if is_cell_occupied(cell_coords):
		push_warning("Cette cellule est déjà occupée : " + str(cell_coords))
		return null
	
	# Convertir en position monde
	var world_pos = map_to_local(cell_coords)
	print("Position monde: ", world_pos)
	
	# Instancier la plante
	var plante_instance = plante_scene.instantiate()
	plante_instance.global_position = world_pos
	print("Plante instanciée: ", plante_instance)
	
	# Ajouter au conteneur
	plants_container.add_child(plante_instance)
	print("Plante ajoutée au conteneur: ", plants_container)
	
	# Marquer la cellule comme occupée
	mark_cell_occupied(cell_coords, plante_instance)
	
	print("✓ Spawn réussi !")
	return plante_instance

func spawn_multiple_plantes(count: int):
	"""Spawne plusieurs plantes sur des blocs cultivables aléatoires"""
	var spawned = 0
	for i in range(count):
		var plante = spawn_plante_on_random_cultivable()
		if plante:
			spawned += 1
		else:
			# Plus de cases disponibles
			break
		await get_tree().create_timer(0.05).timeout
	
	print("Plantes spawnées : ", spawned, "/", count)
	
	if spawned < count:
		print("Attention : Toutes les cases cultivables sont occupées !")

func get_random_available_position() -> Vector2:
	"""Retourne une position cultivable aléatoire non occupée"""
	var available = get_available_cells()
	if available.is_empty():
		return Vector2.ZERO
	var cell = available[randi() % available.size()]
	return map_to_local(cell)

func remove_plante_at_cell(cell_coords: Vector2i):
	"""Supprime la plante à une cellule donnée"""
	if is_cell_occupied(cell_coords):
		var plante = occupied_cells[cell_coords]
		if plante:
			plante.queue_free()
		free_cell(cell_coords)

func clear_all_plants():
	"""Supprime toutes les plantes et libère toutes les cases"""
	for cell in occupied_cells.keys():
		var plante = occupied_cells[cell]
		if plante and is_instance_valid(plante):
			plante.queue_free()
	occupied_cells.clear()

func get_occupied_count() -> int:
	"""Retourne le nombre de cases occupées"""
	return occupied_cells.size()

func get_available_count() -> int:
	"""Retourne le nombre de cases disponibles"""
	return get_available_cells().size()
