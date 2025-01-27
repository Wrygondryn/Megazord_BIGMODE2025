extends Node2D

const JACK_SCENE = preload("res://scenes/jack.tscn")

@onready var sockets: Node2D = $Sockets
@onready var jacks: Node2D = $Jacks
@onready var jack_dispensers: Node2D = $JackDispensers

#TODO: Replace bools with state enum?
var held_jack: Node2D
var currently_holding_jack := false
var mouse_to_jack_centre: Vector2

func hold_jack(jack: Node2D):
	held_jack = jack
	currently_holding_jack = true
	mouse_to_jack_centre = jack.transform.origin - get_local_mouse_position()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	process_jack_selection()
	
	if currently_holding_jack:
		handle_held_jack()
	else:
		process_jack_dispenser()
			
	if Input.is_action_just_released("left_click"):
		currently_holding_jack = false
		
func process_jack_selection():
	var mouse_pos = get_local_mouse_position()
	
	if !currently_holding_jack:
		#Detect is player is about to select a jack
		#TODO: Cache transforms if perfomance is a problem
		for i in range(jacks.get_child_count()):
			var jack = jacks.get_child(i)
			var radius = jack.radius()
			var sqr_dist_from_jack_to_mouse = jack.transform.get_origin().distance_squared_to(mouse_pos)
			var mouse_over_jack = sqr_dist_from_jack_to_mouse <= radius * radius
			if mouse_over_jack and Input.is_action_just_pressed("left_click"):
				hold_jack(jack)
				
func handle_held_jack():
	var mouse_pos = get_local_mouse_position()
	
	#Snap to socket
	var intersecting_socket_pos: Vector2
	var found_intersecting_socket := false
	for socket in sockets.get_children():
		if  mouse_pos.distance_to(socket.global_position) < socket.radius() + held_jack.radius():
			found_intersecting_socket = true
			intersecting_socket_pos = socket.global_position
			break
			
	if found_intersecting_socket:
		held_jack.transform.origin = intersecting_socket_pos
	else: 
		#TODO: Smoothing/Easing
		held_jack.transform.origin = mouse_pos + mouse_to_jack_centre
		
func process_jack_dispenser():
	var mouse_pos = get_local_mouse_position()
	
	#Detect if we clicked on a jack dispenser
	for i in range(jack_dispensers.get_child_count()):
		var dispenser = jack_dispensers.get_child(i)
		var dispenser_interect_rect = dispenser.get_node("Area2D/CollisionShape2D").shape.get_rect()
		dispenser_interect_rect.position = dispenser.global_position - dispenser_interect_rect.size / 2.0
		if dispenser_interect_rect.has_point(mouse_pos) and Input.is_action_just_pressed("left_click"):
			var new_jack = JACK_SCENE.instantiate()
			new_jack.global_position = mouse_pos
			new_jack.set_end_point(dispenser.global_position)
			jacks.add_child(new_jack)
			hold_jack(new_jack)
