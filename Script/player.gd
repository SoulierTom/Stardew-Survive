extends CharacterBody2D

# Paramètres de déplacement
@export var speed: float = 200.0
@export var acceleration: float = 1500.0
@export var friction: float = 1200.0

# Référence au sprite animé (optionnel)
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _physics_process(delta: float) -> void:
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
			animated_sprite.play("idle")
	
	# Déplacer le personnage
	move_and_slide()

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
