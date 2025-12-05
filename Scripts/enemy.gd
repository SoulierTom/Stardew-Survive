extends CharacterBody2D

# Vitesse de déplacement
@export var speed: float = 50.0

# Distance à laquelle l'ennemi commence à cibler une plante
@export var detection_range: float = 500.0

# Distance pour considérer qu'on a atteint la plante
@export var arrival_distance: float = 10.0

# Durée de l'animation "prepare_to_eat" (2 secondes)
const PREPARE_DURATION: float = 2.0

# Référence au sprite animé
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var audio_eat: AudioStreamPlayer2D = $Audio_Eat
@onready var audio_exclam: AudioStreamPlayer2D = $Audio_Exclam

# Sons
@export var eat_plant_sound: AudioStream
@export var exclam_sound: AudioStream

# Plante actuellement ciblée
var target_plant: Node2D = null

# État de l'ennemi
enum State { RUNNING, PREPARING_TO_EAT, EATING }
var current_state: State = State.RUNNING

# Groupe des plantes
const PLANT_GROUP = "plants"

func _ready():
	add_to_group("enemies")
	
	# Animation de course par défaut
	if animated_sprite:
		animated_sprite.play("run")

func _physics_process(delta):
	match current_state:
		State.RUNNING:
			handle_running_state(delta)
		State.PREPARING_TO_EAT:
			handle_preparing_state(delta)
		State.EATING:
			handle_eating_state(delta)
	
	# Appliquer le mouvement
	move_and_slide()

func handle_running_state(delta):
	"""Gère l'état de course vers une plante"""
	# Jouer l'animation de course
	if animated_sprite and animated_sprite.animation != "run":
		animated_sprite.play("run")
	
	# Chercher ou garder la cible
	if not target_plant or not is_instance_valid(target_plant):
		target_plant = find_nearest_plant()
	
	if target_plant:
		# Se déplacer vers la plante
		var direction = (target_plant.global_position - global_position).normalized()
		var distance = global_position.distance_to(target_plant.global_position)
		
		# Retourner le sprite selon la direction
		if animated_sprite and direction.x != 0:
			animated_sprite.flip_h = direction.x < 0
		
		# Vérifier si on est arrivé
		if distance <= arrival_distance:
			# Arrivé à la plante, commencer la préparation
			start_preparing_to_eat()
		else:
			# Continuer à courir
			velocity = direction * speed
	else:
		# Pas de plante, rester immobile
		velocity = Vector2.ZERO

func handle_preparing_state(delta):
	"""Gère l'état de préparation avant de manger"""
	# Ne pas bouger pendant la préparation
	velocity = Vector2.ZERO

func handle_eating_state(delta):
	"""Gère l'état de manger"""
	# Ne pas bouger pendant qu'on mange
	velocity = Vector2.ZERO

func start_preparing_to_eat():
	"""Commence la phase de préparation à manger"""
	print("Ennemi : Préparation à manger...")
	current_state = State.PREPARING_TO_EAT
	velocity = Vector2.ZERO
	
	# Jouer l'animation de préparation
	if animated_sprite:
		animated_sprite.play("prepare_to_eat")
	
	play_exclam_sound()
	
	# Attendre 2 secondes puis manger
	await get_tree().create_timer(PREPARE_DURATION).timeout
	
	# Vérifier que la plante existe encore
	if is_instance_valid(target_plant):
		start_eating()
	else:
		# La plante a disparu, reprendre la course
		current_state = State.RUNNING
		target_plant = null

func start_eating():
	"""Commence à manger la plante"""
	print("Ennemi : Mange la plante !")
	current_state = State.EATING
	
	# Jouer l'animation de manger
	if animated_sprite:
		animated_sprite.play("eating")
	
	# Jouer le son
	play_eat_sound()
	
	# Attendre que l'animation se termine (ou durée fixe)
	var eating_duration = get_eating_animation_duration()
	await get_tree().create_timer(eating_duration).timeout
	
	# Détruire la plante
	if target_plant and is_instance_valid(target_plant):
		if target_plant.has_method("destroy"):
			target_plant.destroy()
		else:
			target_plant.queue_free()
	
	# Réinitialiser et chercher une nouvelle cible
	target_plant = null
	current_state = State.RUNNING
	
	print("Ennemi : Recherche d'une nouvelle plante...")

func get_eating_animation_duration() -> float:
	"""Retourne la durée de l'animation 'eating'"""
	if animated_sprite and animated_sprite.sprite_frames:
		var frames = animated_sprite.sprite_frames
		if frames.has_animation("eating"):
			var frame_count = frames.get_frame_count("eating")
			var fps = frames.get_animation_speed("eating")
			if fps > 0:
				return frame_count / fps
	
	# Durée par défaut si on ne peut pas calculer
	return 0.5

func find_nearest_plant() -> Node2D:
	"""Trouve la plante la plus proche dans la portée de détection"""
	var plants = get_tree().get_nodes_in_group(PLANT_GROUP)
	
	if plants.is_empty():
		return null
	
	var nearest_plant: Node2D = null
	var nearest_distance: float = detection_range
	
	for plant in plants:
		if not is_instance_valid(plant):
			continue
		
		var distance = global_position.distance_to(plant.global_position)
		
		if distance < nearest_distance:
			nearest_distance = distance
			nearest_plant = plant
	
	return nearest_plant

func play_exclam_sound():
	"""Joue le son de destruction de plante"""
	if audio_exclam and exclam_sound:
		audio_exclam.stream = exclam_sound
		audio_exclam.play()

func play_eat_sound():
	"""Joue le son de destruction de plante"""
	if audio_eat and eat_plant_sound:
		audio_eat.stream = eat_plant_sound
		audio_eat.play()

func take_damage(amount: int = 1):
	"""L'ennemi prend des dégâts"""
	print("Ennemi touché !")
	queue_free()
