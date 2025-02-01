extends Control


@onready var pages: Control = $Pages
@onready var next_button: Button = $NextButton
@onready var back_prev_button: Button = $BackPrevButton

var current_page_index: int = 0


signal leaving

func _on_next_button_pressed() -> void:
	pages.get_child(current_page_index).hide()
	current_page_index = min(current_page_index + 1, pages.get_child_count() - 1)
	pages.get_child(current_page_index).show()
	
	if current_page_index == pages.get_child_count() - 1:
		next_button.hide()	

func _on_back_prev_button_pressed() -> void:
	next_button.show()
	
	if current_page_index == 0:
		leaving.emit()
	
	pages.get_child(current_page_index).hide()	
	current_page_index = max(current_page_index - 1, 0)
	pages.get_child(current_page_index).show()

func _process(delta: float) -> void:
	back_prev_button.text = "Back" if current_page_index == 0 else "Previous"
