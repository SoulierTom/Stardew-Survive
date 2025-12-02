extends Control

@onready var firstlevel = preload("res://Scenes/main_level.tscn")

func _on_start_button_button_down() -> void:
	get_tree().change_scene_to_packed(firstlevel)

func _on_quit_button_button_down() -> void:
	get_tree().quit()
