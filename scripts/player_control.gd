extends Node2D

@onready var sockets: Node2D = $Sockets
@onready var jacks: Node2D = $Jacks

#TODO: Replace bools with state enum
var held_jack: Node2D
var currently_holding_jack := false
var mouse_to_jack_centre: Vector2

#TODO: Make these const somehow?
var jack_radius: float
var socket_radius: float 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var jack_sprite = jacks.get_child(0).get_node("Sprite2D")
	jack_radius = jack_sprite.transform.get_scale().x * jack_sprite.texture.get_width() / 2.0
	
	var socket_sprite = sockets.get_child(0).get_node("Sprite2D")
	socket_radius = socket_sprite.transform.get_scale().x * socket_sprite.texture.get_width() / 2.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var mouse_pos = get_local_mouse_position()
	
	if !currently_holding_jack:
		#TODO: Cache transforms if perfomance is a problem
		for i in range(jacks.get_child_count()):
			var jack = jacks.get_child(i)
			var sqr_dist_from_jack_to_mouse = jack.transform.get_origin().distance_squared_to(mouse_pos)
			var mouse_over_jack = sqr_dist_from_jack_to_mouse <= jack_radius * jack_radius
			if mouse_over_jack and Input.is_action_just_pressed("jack_select"):
				print("yerp")
				held_jack = jack
				currently_holding_jack = true
				mouse_to_jack_centre = jack.transform.origin - mouse_pos
	
	if currently_holding_jack:
		var intersecting_socket_pos: Vector2
		var found_intersecting_socket := false
		for socket in sockets.get_children():
			if  mouse_pos.distance_to(socket.global_position) < (socket_radius + jack_radius):
				found_intersecting_socket = true
				intersecting_socket_pos = socket.global_position
				break
		
		if found_intersecting_socket:
			held_jack.transform.origin = intersecting_socket_pos
		else: 
			#TODO: Smoothing/Easing
			held_jack.transform.origin = mouse_pos + mouse_to_jack_centre
			
	if Input.is_action_just_released("jack_select"):
		currently_holding_jack = false
		
