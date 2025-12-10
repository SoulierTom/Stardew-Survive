extends Control

@onready var firstlevel = preload("res://Scenes/main_level.tscn")

func _on_texture_button_start_pressed() -> void:
	await get_tree().create_timer(1).timeout
	get_tree().change_scene_to_packed(firstlevel)
	
func _on_texture_button_quit_pressed() -> void:
	get_tree().quit(0)
