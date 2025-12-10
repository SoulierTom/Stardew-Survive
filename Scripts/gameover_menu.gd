extends Control

@onready var firstlevel = preload("res://Scenes/main_level.tscn")
@onready var mainmenu = preload("res://Scenes/main_menu.tscn")

func _on_retry_button_button_down() -> void:
	await get_tree().create_timer(1).timeout
	get_tree().change_scene_to_packed(firstlevel)


func _on_main_menu_button_button_down() -> void:
	await get_tree().create_timer(1).timeout
	get_tree().change_scene_to_packed(mainmenu)


func _on_quit_button_button_down() -> void:
	get_tree().quit()
