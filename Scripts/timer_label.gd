extends Label

# Durée totale du compte à rebours (1 min 30 = 90 secondes)
const TOTAL_TIME := 90.0

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
