extends Label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	text = "Score: " + str(game_manager.score)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	text = "Score: " + str(game_manager.score)
