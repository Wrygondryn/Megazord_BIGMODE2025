extends Node2D

const JACK_SCENE = preload("res://scenes/jack.tscn")

@onready var sockets: Node2D = $Sockets
@onready var jacks: Node2D = $Jacks
@onready var jack_dispensers: Node2D = $JackDispensers

#NOTE: I think this should work since StringName is meant to be unique? Don't @ me
class JackSocketConnection:
	var jack_name: StringName
	var socket_name: StringName
	
	func _init(jack_name, socket_name: StringName):
		self.jack_name = jack_name
		self.socket_name = socket_name

#TODO: Consider changing to Dict[Jack, Socket]? Depends whether we need to get
#the jack from the socket (i.e., we wanna go both ways)
var connections: Array[JackSocketConnection] = []

#TODO: Replace bools with state enum?
var held_jack: Node2D = null
var mouse_to_jack_centre: Vector2

#Removes an element from an array, and simply places the end element in the array
#to the removed spot. O(1) computation time. Returns true if remove was successful.
#NOTE: This will screw up array order, so only use on arrays whose order you do 
#not care about. 
static func arr_swap_remove(arr: Array, at: int) -> bool:
	var orig_len = len(arr)
	var last_el = arr.pop_back()
	if last_el != null && at < orig_len - 1:
		arr[at] = last_el
		return true
	else:
		return last_el != null

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
			disconnect_jack(held_jack.name)
			
			var should_connect_held_jack := false
			var intersecting_socket := socket_intersecting_jack(held_jack)
			print(intersecting_socket != null)
			if intersecting_socket != null:
				var prev_connection := connection_from_name(held_jack.name)
				var was_connected_to_socket := prev_connection != null && prev_connection.socket_name == intersecting_socket.name
				var socket_already_connected := name_is_connected(intersecting_socket.name)
				should_connect_held_jack =  was_connected_to_socket || !socket_already_connected
			
			if should_connect_held_jack:
				var new_connection := JackSocketConnection.new(held_jack.name, intersecting_socket.name)
				connections.append(new_connection)
				
		held_jack = null

func name_is_connected(jack_or_socket_name: StringName) -> bool:
	for connection in connections:
		if jack_or_socket_name == connection.jack_name || jack_or_socket_name == connection.socket_name:
			return true
	return false
	
func connection_from_name(jack_or_socket_name: StringName) -> JackSocketConnection:
	for connection in connections:
		if jack_or_socket_name == connection.jack_name || jack_or_socket_name == connection.socket_name:
			return connection
	return null


#NOTE: Returns whether jack was successfully disconnected
func disconnect_jack(jack_name: StringName) -> bool:
	for i in range(len(connections)):
		if jack_name == connections[i].jack_name:
			assert(arr_swap_remove(connections, i))
			return true
	return false

func socket_intersecting_jack(jack: Node2D) -> Node2D:
	var mouse_pos = get_local_mouse_position()
	
	for socket in sockets.get_children():	
		var d = mouse_pos.distance_to(socket.global_position)
		var sr = socket.radius()  
		var jr = jack.radius()
		
		var intersecting_socket = d < sr + jr
		if intersecting_socket:
			return socket
	
	return null

#Detect is player is about to select a jack
func process_jack_selection():
	if held_jack != null: return
	
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
	var should_snap = false
	
	var intersecting_socket := socket_intersecting_jack(held_jack)
	if intersecting_socket != null:
		var prev_connection := connection_from_name(held_jack.name)
		var was_connected_to_socket := prev_connection != null && prev_connection.socket_name == intersecting_socket.name
		var socket_already_connected := name_is_connected(intersecting_socket.name)
		should_snap = was_connected_to_socket || !socket_already_connected
	
	if should_snap:
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
