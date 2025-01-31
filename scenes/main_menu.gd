extends Control

@onready var main: Node = $Main
@onready var credits: Control = $Credits


func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/game.tscn")

func _on_quit_button_pressed() -> void:
	get_tree().quit()

func _on_credits_button_pressed() -> void:
	toggle_main_menu_visibility(false)
	credits.show()

func _on_credits_back_button_pressed() -> void:
	toggle_main_menu_visibility(true)
	credits.hide()


func toggle_main_menu_visibility(shown: bool) -> void:
	for button in main.get_node("Buttons").get_children():
		button.disabled = !shown
		
	if shown: 
		main.show()
	else:
		main.hide()
