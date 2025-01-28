extends Node2D

const JACK_SCENE = preload("res://scenes/jack.tscn")

@onready var sockets: Node2D = $Sockets
@onready var jacks: Node2D = $Jacks
@onready var jack_dispensers: Node2D = $JackDispensers

#TODO: Replace bools with state enum?
var held_jack: Node2D = null
var mouse_to_jack_centre: Vector2


func hold_jack(jack: Node2D):
	held_jack = jack
	mouse_to_jack_centre = jack.transform.origin - get_local_mouse_position()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	process_jack_selection()
	
	if held_jack != null:
		handle_held_jack()
	else:
		process_jack_dispenser()
			
	if Input.is_action_just_released("left_click"): 
		if held_jack != null:
			var intersecting_socket = socket_intersecting_jack(held_jack)
			if intersecting_socket != null:
				held_jack.plug_into(intersecting_socket)
			elif held_jack.plugged_socket != null:
				held_jack.unplug()
				
		held_jack = null


func socket_intersecting_jack(jack: Node2D) -> Node2D:
	var result: Node2D = null
	var found_intersecting_socket := false
	for socket in sockets.get_children():
		var mouse_pos = get_local_mouse_position()
		var intersecting_socket = mouse_pos.distance_to(socket.global_position) < socket.radius() + jack.radius()
		if !socket.plugged && intersecting_socket:
			found_intersecting_socket = true
			result = socket
			break
	
	return result

func process_jack_selection():
	if held_jack == null:
		#Detect is player is about to select a jack
		#TODO: Cache transforms if perfomance is a problem
		var mouse_pos = get_local_mouse_position()
		for i in range(jacks.get_child_count()):
			var jack = jacks.get_child(i)
			var radius = jack.radius()
			var sqr_dist_from_jack_to_mouse = jack.transform.get_origin().distance_squared_to(mouse_pos)
			var mouse_over_jack = sqr_dist_from_jack_to_mouse <= radius * radius
			if mouse_over_jack and Input.is_action_just_pressed("left_click"):
				hold_jack(jack)
				
func handle_held_jack():
	var intersecting_socket := socket_intersecting_jack(held_jack)
	if intersecting_socket != null:
		held_jack.transform.origin = intersecting_socket.global_position
	else: 
		#TODO: Smoothing/Easing
		var mouse_pos = get_local_mouse_position()
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
