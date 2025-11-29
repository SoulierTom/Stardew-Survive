extends Label

# Variables pour le timer
var game_time: float = 0.0
var is_game_running: bool = false

func _ready():
	start_game()

func _process(delta):
	if is_game_running:
		game_time += delta
		update_timer_display()

func start_game():
	"""Démarre le chronomètre"""
	game_time = 0.0
	is_game_running = true

func stop_game():
	"""Arrête le chronomètre"""
	is_game_running = false

func pause_game():
	"""Met en pause le chronomètre"""
	is_game_running = false

func resume_game():
	"""Reprend le chronomètre"""
	is_game_running = true

func update_timer_display():
	"""Met à jour l'affichage du timer"""
	var minutes = int(game_time) / 60
	var seconds = int(game_time) % 60
	var milliseconds = int((game_time - int(game_time)) * 100)
	
	var time_string = "%02d:%02d:%02d" % [minutes, seconds, milliseconds]
	
	# Si vous avez un Label dans votre scène :
	text = time_string
