extends Control

@onready var firstlevel = preload("res://Scenes/main_level.tscn")
@onready var mainmenu = preload("res://Scenes/main_menu.tscn")

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	z_index = 100
	z_as_relative = false
	
	# Remplir tout l'écran
	set_anchors_preset(Control.PRESET_FULL_RECT)
	set_offsets_preset(Control.PRESET_FULL_RECT)
	
	# Forcer la mise à jour de la taille
	size = get_viewport_rect().size
	
	# Ajouter le fond semi-transparent
	add_background()
	
	# Redimensionner les éléments du menu
	adjust_menu_scale()

func add_background():
	"""Ajoute un fond noir semi-transparent derrière le menu"""
	var background = ColorRect.new()
	background.color = Color(110, 0, 0, 0.25)  # Noir avec 70% d'opacité
	background.mouse_filter = Control.MOUSE_FILTER_STOP  # Bloque les clics en dessous
	
	# Remplir tout l'écran
	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	background.set_offsets_preset(Control.PRESET_FULL_RECT)
	background.size = get_viewport_rect().size
	
	# Ajouter comme premier enfant (derrière tout)
	add_child(background)
	move_child(background, 0)

func adjust_menu_scale():
	"""Ajuste l'échelle du contenu du menu pour qu'il soit visible"""
	var viewport_size = get_viewport_rect().size
	
	# Chercher le container principal (VBoxContainer, PanelContainer, etc.)
	for child in get_children():
		if child is VBoxContainer or child is PanelContainer or child is MarginContainer:
			# Centrer le container
			child.position = viewport_size / 2
			child.pivot_offset = child.size / 2
			
			# Si le menu est trop grand, le réduire
			var scale_factor = min(
				viewport_size.x / (child.size.x + 100),
				viewport_size.y / (child.size.y + 100)
			)
			
			if scale_factor < 1:
				child.scale = Vector2(scale_factor, scale_factor)

func _on_retry_button_button_down() -> void:
	get_tree().paused = false
	queue_free()
	await get_tree().create_timer(1).timeout
	get_tree().change_scene_to_packed(firstlevel)

func _on_main_menu_button_button_down() -> void:
	get_tree().paused = false
	queue_free()
	get_tree().change_scene_to_packed(mainmenu)

func _on_quit_button_button_down() -> void:
	get_tree().paused = false
	queue_free()
	get_tree().quit()
