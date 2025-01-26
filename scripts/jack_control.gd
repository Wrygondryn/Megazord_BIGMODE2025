extends Node2D

var held_jack: Node2D
var currently_holding_jack: bool = false
var mouse_to_jack_centre: Vector2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var mouse_pos = get_local_mouse_position()
	
	if !currently_holding_jack:
		#TODO: Cache transforms if perfomance is a problem
		for i in range(get_child_count()):
			var jack = get_child(i)
			var sprite = jack.get_node("Sprite2D")
			var radius = sprite.transform.get_scale().x * sprite.texture.get_width()
			var mouse_over_jack = jack.transform.get_origin().distance_squared_to(mouse_pos) <= radius * radius
			if mouse_over_jack and Input.is_action_just_pressed("jack_select"):
				print("yerp")
				held_jack = jack
				currently_holding_jack = true
				mouse_to_jack_centre = jack.transform.origin - mouse_pos
	
	if currently_holding_jack:
		#TODO: Smoothing/Easing
		held_jack.transform.origin = mouse_pos + mouse_to_jack_centre
			
	if Input.is_action_just_released("jack_select"):
		currently_holding_jack = false
		
