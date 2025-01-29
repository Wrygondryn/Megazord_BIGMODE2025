extends Node2D

@onready var sockets: Node2D = $Sockets
@onready var jacks: Node2D = $Jacks
@onready var jack_dispensers: Node2D = $JackDispensers

#NOTE: I think this should work since StringName is meant to be unique? Don't @ me
class JackSocketConnection:
	var jack_instance_id: int
	var socket_instance_id: int
	
	func _init(jack_instance_id, socket_instance_id: int):
		self.jack_instance_id = jack_instance_id
		self.socket_instance_id = socket_instance_id

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
			release_held_jack()
		held_jack = null
		
	display_powers()


func is_connected_by_id(jack_or_socket_id: int) -> bool:
	for connection in connections:
		if jack_or_socket_id == connection.jack_instance_id || jack_or_socket_id == connection.socket_instance_id:
			return true
	return false
	
func connection_from_id(jack_or_socket_id: int) -> JackSocketConnection:
	for connection in connections:
		if jack_or_socket_id == connection.jack_instance_id || jack_or_socket_id == connection.socket_instance_id:
			return connection
	return null

#NOTE: Returns whether jack was successfully disconnected
func disconnect_jack(jack_instance_id: int) -> bool:
	for i in range(len(connections)):
		if jack_instance_id == connections[i].jack_instance_id:
			var socket := instance_from_id(connections[i].socket_instance_id)
			assert(arr_swap_remove(connections, i))
			
			return true
	
	return false

func socket_intersecting_jack(jack: Node2D) -> Node2D:
	var mouse_pos = get_local_mouse_position()
	
	for socket in sockets.get_children():	
		if mouse_pos.distance_to(socket.global_position) < socket.radius() + jack.radius():
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
		var prev_connection := connection_from_id(held_jack.get_instance_id())
		var was_connected_to_socket := prev_connection != null && prev_connection.socket_instance_id == intersecting_socket.get_instance_id()
		var socket_already_connected := is_connected_by_id(intersecting_socket.get_instance_id())
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
			var new_jack = dispenser.new_jack()
			new_jack.global_position = mouse_pos
			jacks.add_child(new_jack)
			hold_jack(new_jack)

func release_held_jack():
	disconnect_jack(held_jack.get_instance_id())
			
	#TODO: Refactor into function? There's another body of code that's pretty much the same
	#but it still needs the intersecting socket as well
	var should_connect_held_jack := false
	var intersecting_socket := socket_intersecting_jack(held_jack)
	if intersecting_socket != null:
		var prev_connection := connection_from_id(held_jack.get_instance_id())
		var was_connected_to_socket := prev_connection != null && prev_connection.socket_instance_id == intersecting_socket.get_instance_id()
		var socket_already_connected := is_connected_by_id(intersecting_socket.get_instance_id())
		should_connect_held_jack =  was_connected_to_socket || !socket_already_connected
	
	if should_connect_held_jack:
		var new_connection := JackSocketConnection.new(held_jack.get_instance_id(), intersecting_socket.get_instance_id())
		connections.append(new_connection)
	
	recalculate_module_cooldowns()

#TODO: If performance tanks because of this, figure out a way for us not to have 
#to iterate through children each iteration of outer loop (i.e., make map from 
#connection to socket.jack O(1) or O(log(n)) or something)
func display_powers():
	for i in range(sockets.get_child_count()):
		sockets.get_child(i).power_display_temp.text = "0"
	
	for connection in connections:
		var power = instance_from_id(connection.jack_instance_id).power
		var socket := instance_from_id(connection.socket_instance_id)
		socket.power_display_temp.text = str(power)

func recalculate_module_cooldowns():
	var total_power = connections.reduce(
		func (acc: float, connection: JackSocketConnection) -> float: 
			var power = instance_from_id(connection.jack_instance_id).power 
			return acc + power,
		0.0
	)
	
	for i in range(sockets.get_child_count()):
		sockets.get_child(i).module.set_proportional_charge_rate(0.0)
		
	for connection in connections:
		var power = instance_from_id(connection.jack_instance_id).power
		var socket := instance_from_id(connection.socket_instance_id)
		#TODO: Figure out a way to not have to mutate state between objects, it seems very
		#easy to mess up and leak bugs
		socket.module.set_proportional_charge_rate(power / total_power)
