extends Node2D



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	click_rect.position = global_position - click_rect.size / 2.0


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
