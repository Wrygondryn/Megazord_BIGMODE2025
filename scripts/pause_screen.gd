extends Control


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("pause_game"):
		get_tree().paused = !get_tree().paused
		
		if get_tree().paused: 
			show()
		else:
			hide()


func _on_resume_button_pressed() -> void:
	get_tree().paused = false
	hide()

func _on_quit_button_pressed() -> void:
	get_tree().quit()
