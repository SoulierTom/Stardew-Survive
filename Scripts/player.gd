extends CharacterBody2D

# Paramètres de déplacement
@export var speed: float = 200.0
@export var acceleration: float = 1500.0
@export var friction: float = 1200.0

# Paramètres d'attaque
@export var attack_cooldown: float = 0.5  # Temps entre deux attaques
@export var attack_range: float = 30.0  # Portée de l'attaque

# Référence au sprite animé (optionnel)
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

# Variables d'attaque
var can_attack: bool = true
var attack_timer: float = 0.0

func _physics_process(delta: float) -> void:
	# Gestion du cooldown d'attaque
	if not can_attack:
		attack_timer -= delta
		if attack_timer <= 0:
			can_attack = true
	
	# Récupérer les inputs du joueur
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_axis("move_left", "move_right")
	input_vector.y = Input.get_axis("move_up", "move_down")
	
	# Normaliser le vecteur pour éviter le déplacement plus rapide en diagonal
	input_vector = input_vector.normalized()
	
	# Appliquer le mouvement avec accélération/friction
	if input_vector != Vector2.ZERO:
		# Accélération
		velocity = velocity.move_toward(input_vector * speed, acceleration * delta)
		
		# Gestion des animations (optionnel)
		update_animation(input_vector)
	else:
		# Friction quand aucune touche n'est pressée
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
		
		# Animation idle
		if animated_sprite:
			animated_sprite.play("Idle")
	
	# Déplacer le personnage
	move_and_slide()

func _input(event):
	# Attaque avec la barre d'espace ou clic gauche
	if event.is_action_pressed("Attack"):
		attack()

func attack():
	"""Attaque les ennemis à portée"""
	if not can_attack:
		return
	
	print("Attaque !")
	
	# Animation d'attaque (optionnel)
	if animated_sprite and animated_sprite.sprite_frames.has_animation("attack"):
		animated_sprite.play("attack")
	
	# Trouver tous les ennemis
	var enemies = get_tree().get_nodes_in_group("enemies")
	
	for enemy in enemies:
		if not is_instance_valid(enemy):
			continue
		
		# Vérifier la distance
		var distance = global_position.distance_to(enemy.global_position)
		
		if distance <= attack_range:
			# Ennemi à portée, le détruire
			if enemy.has_method("take_damage"):
				enemy.take_damage()
			else:
				enemy.queue_free()
			
			print("Ennemi détruit !")
	
	# Activer le cooldown
	can_attack = false
	attack_timer = attack_cooldown

# Fonction pour gérer les animations selon la direction
func update_animation(direction: Vector2) -> void:
	if not animated_sprite:
		return
	
	# Déterminer la direction principale
	if abs(direction.x) > abs(direction.y):
		# Mouvement horizontal
		if direction.x > 0:
			animated_sprite.play("walk_right")
		else:
			animated_sprite.play("walk_left")
	else:
		# Mouvement vertical
		if direction.y > 0:
			animated_sprite.play("walk_down")
		else:
			animated_sprite.play("walk_up")
