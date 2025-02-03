extends Control


@onready var volume_slider: HSlider = $VolumeSlider


func _ready():
	var starting_volume := AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master"))
	var starting_volume_frac = (starting_volume - Helpers.MIN_VOLUME_DB) / (Helpers.MAX_VOLUME_DB - Helpers.MIN_VOLUME_DB)
	volume_slider.value = (volume_slider.max_value - volume_slider.min_value) * starting_volume_frac

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("pause_game"):
		get_tree().paused = !get_tree().paused
		
		if get_tree().paused: 
			show()
		else:
			hide()

func _on_volume_slider_value_changed(value: float) -> void:
	var new_volume := Helpers.MIN_VOLUME_DB + (Helpers.MAX_VOLUME_DB - Helpers.MIN_VOLUME_DB) * value / volume_slider.max_value
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), new_volume)

func _on_resume_button_pressed() -> void:
	get_tree().paused = false
	hide()

func _on_quit_button_pressed() -> void:
	get_tree().quit()
