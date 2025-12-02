extends CharacterBody2D

# Vitesse de déplacement
@export var speed: float = 50.0

# Distance à laquelle l'ennemi commence à cibler une plante
@export var detection_range: float = 500.0

# Distance pour considérer qu'on a atteint la plante
@export var arrival_distance: float = 10.0

# Durée de l'animation de changement de cible (en secondes)
@export var target_change_duration: float = 0.6

# Référence au sprite
@onready var sprite: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D

# Son à jouer lors du changement de cible
@export var target_change_sound: AudioStream
# Son à jouer lors de la destruction d'une plante
@export var eat_plant_sound: AudioStream

# Plante actuellement ciblée
var target_plant: Node2D = null
var previous_target: Node2D = null

# État de l'ennemi
var is_changing_target: bool = false

# Groupe des plantes (à définir dans votre scène de plante)
const PLANT_GROUP = "plants"

func _ready():
	# Optionnel : ajouter l'ennemi à un groupe pour faciliter la gestion
	add_to_group("enemies")

func _physics_process(delta):
	# Ne pas bouger pendant le changement de cible
	if is_changing_target:
		velocity = Vector2.ZERO
		move_and_slide()
		return
	
	# Si on a déjà une cible valide, la garder
	if target_plant and is_instance_valid(target_plant):
		# Ne rien faire, on garde la cible actuelle
		pass
	else:
		# La cible est morte ou n'existe plus, en trouver une nouvelle
		var new_target = find_nearest_plant()
		
		# Détecter si la cible a changé
		if new_target != previous_target:
			on_target_changed(new_target)
			previous_target = new_target
		
		target_plant = new_target
	
	if target_plant:
		move_towards_plant(delta)
	else:
		# Pas de plante à proximité, comportement par défaut
		idle_behavior(delta)
	
	# Appliquer le mouvement
	move_and_slide()

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
		
		# Vérifier si c'est dans la portée et plus proche
		if distance < nearest_distance:
			nearest_distance = distance
			nearest_plant = plant
	
	return nearest_plant

func move_towards_plant(delta):
	"""Se déplace vers la plante ciblée"""
	if not is_instance_valid(target_plant):
		target_plant = null
		return
	
	var direction = (target_plant.global_position - global_position).normalized()
	var distance = global_position.distance_to(target_plant.global_position)
	
	# Si on est assez proche, attaquer/manger la plante
	if distance <= arrival_distance:
		attack_plant()
	else:
		# Se déplacer vers la plante
		velocity = direction * speed
		
		# Optionnel : retourner le sprite selon la direction
		if direction.x < 0:
			sprite.flip_h = true
		else:
			sprite.flip_h = false

func idle_behavior(delta):
	"""Comportement quand aucune plante n'est à portée"""
	# Option 1 : Ne rien faire
	velocity = Vector2.ZERO
	
	# Option 2 : Patrouiller aléatoirement
	# velocity = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized() * speed * 0.3

func attack_plant():
	"""Attaque/mange la plante"""
	if is_instance_valid(target_plant):
		print("Ennemi mange la plante !")
		
		# Jouer l'animation et le son de destruction
		is_changing_target = true
		play_eat_animation()
		play_eat_sound()
		
		# Attendre la fin de l'animation avant de détruire
		await get_tree().create_timer(target_change_duration).timeout
		
		# Notifier la plante qu'elle est détruite (elle libère sa case automatiquement)
		if target_plant and is_instance_valid(target_plant):
			if target_plant.has_method("destroy"):
				target_plant.destroy()
			else:
				# Fallback : détruire directement
				target_plant.queue_free()
		
		# Réinitialiser la cible et previous_target pour permettre une nouvelle recherche
		target_plant = null
		previous_target = null
		is_changing_target = false
		
		# Optionnel : l'ennemi disparaît après avoir mangé
		# queue_free()

func take_damage(amount: int = 1):
	"""L'ennemi prend des dégâts"""
	print("Ennemi touché !")
	queue_free()  # Pour l'instant, meurt en un coup

func _on_area_entered(area):
	"""Optionnel : détection par Area2D"""
	if area.is_in_group(PLANT_GROUP):
		target_plant = area.get_parent()

func on_target_changed(new_target: Node2D):
	"""Appelé quand l'ennemi change de cible"""
	# Bloquer le mouvement pendant l'animation
	is_changing_target = true
	
	if new_target == null:
		print("Ennemi : Plus de cible")
		await play_idle_animation()
	
	# Débloquer le mouvement après l'animation
	is_changing_target = false


func play_idle_animation():
	"""Joue l'animation d'inactivité"""
	if animation_player and animation_player.has_animation("idle"):
		animation_player.play("idle")
		await animation_player.animation_finished
	else:
		# Petite pause
		await get_tree().create_timer(0.2).timeout

func play_eat_sound():
	"""Joue le son de destruction de plante"""
	if audio_player and eat_plant_sound:
		audio_player.stream = eat_plant_sound
		audio_player.play()
	elif audio_player:
		print("Aucun son assigné pour manger la plante")

func play_eat_animation():
	"""Joue l'animation de destruction de plante"""
	if animation_player and animation_player.has_animation("eat"):
		animation_player.play("eat")
	else:
		# Animation par code : manger/mordre
		eat_bounce_animation()

func eat_bounce_animation():
	"""Animation de morsure/manger par code"""
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_IN_OUT)
	
	# Effet de "morsure" : avancer rapidement puis reculer
	var original_pos = position
	var bite_distance = 5
	var direction = (target_plant.global_position - global_position).normalized()
	
	# Avancer vers la plante
	tween.tween_property(self, "position", position + direction * bite_distance, target_change_duration * 0.3)
	# Reculer
	tween.tween_property(self, "position", original_pos, target_change_duration * 0.3)
	
	# Effet de scale (bouche qui s'ouvre/ferme)
	tween.parallel().tween_property(self, "scale", Vector2(1.3, 0.8), target_change_duration * 0.3)
	tween.tween_property(self, "scale", Vector2.ONE, target_change_duration * 0.3)
