extends Label

@onready var gameovermenu = preload("res://Scenes/gameover_menu.tscn")
var pause_instance = null

# Durée totale du compte à rebours (1 min 30 = 90 secondes)
const TOTAL_TIME := 3
var remaining_time: float = TOTAL_TIME
var is_running: bool = false

func _ready():
	start_countdown()

func _process(delta):
	if is_running:
		remaining_time -= delta
		
		# Empêche le timer de passer sous 0
		if remaining_time < 0:
			remaining_time = 0
			is_running = false
			on_timer_finished()
		update_display()

func start_countdown():
	"""Lance le compte à rebours"""
	remaining_time = TOTAL_TIME
	is_running = true

func stop_countdown():
	"""Arrête le timer définitivement"""
	is_running = false

func pause_countdown():
	"""Met en pause"""
	is_running = false

func resume_countdown():
	"""Reprend"""
	is_running = true

func update_display():
	"""Affiche le temps restant"""
	var minutes := int(remaining_time) / 60
	var seconds := int(remaining_time) % 60
	var milliseconds := int((remaining_time - int(remaining_time)) * 100)
	text = "%02d:%02d:%02d" % [minutes, seconds, milliseconds]

func on_timer_finished():
	if pause_instance == null:
		var mainlevel = get_tree().current_scene
		print("GameOver")
		get_tree().paused = true
		pause_instance = gameovermenu.instantiate()
		
		# Définir z-index élevé
		pause_instance.z_index = 100
		pause_instance.z_as_relative = false
		
		# Centrer à l'écran
		if pause_instance is Control:
			pause_instance.set_anchors_preset(Control.PRESET_CENTER)
			pause_instance.position = get_viewport_rect().size / 2 - pause_instance.size / 2
		
		mainlevel.add_child(pause_instance)
