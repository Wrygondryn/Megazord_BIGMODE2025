extends Control

@onready var main: Node = $Main
@onready var credits: Control = $Credits
@onready var tutorial: Control = $Tutorial

@onready var settings: Control = $Settings
@onready var volume_slider: HSlider = $Settings/VolumeSlider

const MIN_VOLUME_DB = -24.0
const MAX_VOLUME_DB = 0.0


func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/game.tscn")


func _on_tutorial_button_pressed() -> void:
	main.hide()
	tutorial.show()

func _on_tutorial_leaving() -> void:
	tutorial.hide()
	main.show()


func _on_credits_button_pressed() -> void:
	toggle_main_menu_visibility(false)
	credits.show()

func _on_credits_back_button_pressed() -> void:
	toggle_main_menu_visibility(true)
	credits.hide()


func _on_settings_button_pressed() -> void:
	toggle_main_menu_visibility(false)
	settings.show()

func _on_volume_slider_value_changed(value: float) -> void:

	
	var new_volume := MIN_VOLUME_DB + (MAX_VOLUME_DB - MIN_VOLUME_DB) * value / volume_slider.max_value
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), new_volume)

func _on_settings_back_button_pressed() -> void:
	toggle_main_menu_visibility(true)
	settings.hide()


func _on_quit_button_pressed() -> void:
	get_tree().quit()


func toggle_main_menu_visibility(shown: bool) -> void:
	for button in main.get_node("Buttons").get_children():
		button.disabled = !shown
		
	if shown: 
		main.show()
	else:
		main.hide()
