extends Node2D
	

class ActionInfo:
	var actor: Helpers.GigaTarget
	var source_body_part: Node2D
	var animation: AnimationPlayer
	
	var action: Action
	
	func _init(body_part: Node2D, action: Action, animation: AnimationPlayer):
		self.action = action
		
		source_body_part = body_part
		self.animation = animation
	
	
@onready var mechazord: Node2D = $Mechazord
@onready var kaiju: Node2D = $Kaiju

var game_over := false
var action_queue: Array[ActionInfo]
var current_mech_action: ActionInfo = null
var current_kaiju_action: ActionInfo = null


func queue_action(body_part: Node2D, action: Action, animation: AnimationPlayer):
	action_queue.append(ActionInfo.new(body_part, action, animation))


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if game_over: return
	
	#TODO: Wait until animation of currently executed action is complete until processing the next
	#NOTE: Mechazord and Kaiju actions can happen simultaneously, so make sure to check for that when
	#animations get integrated
	
	if current_mech_action == null:
		var next_mech_action_index: int = -1
		for i in range(0, len(action_queue)):
			if action_queue[i].actor == Helpers.GigaTarget.MECHAZORD:
				next_mech_action_index = i
				break
		
		if next_mech_action_index >= 0:
			current_mech_action = action_queue[next_mech_action_index]
			action_queue.remove_at(next_mech_action_index)
			#TODO: Process Action at a given keyframe or some shit
			process_action(current_mech_action)
			current_mech_action.animation.play()
	
	if current_kaiju_action == null:
		var next_kaiju_action_index: int = -1
		for i in range(0, len(action_queue)):
			if action_queue[i].actor == Helpers.GigaTarget.KAIJU:
				next_kaiju_action_index = i
				break
		
		if next_kaiju_action_index >= 0:
			current_kaiju_action = action_queue[next_kaiju_action_index]
			action_queue.remove_at(next_kaiju_action_index)
			#TODO: Process Action at a given keyframe or some shit
			process_action(current_kaiju_action)
			current_kaiju_action.animation.play()
			
	if !current_mech_action.animation.is_playing():
		current_mech_action = null 
		
	if !current_kaiju_action.animation.is_playing():
		current_kaiju_action = null

func kaiju_victory():
	print("You Lose!")
	game_over = true
	
func mechazord_victory():
	print("You Win!")
	game_over = true

func process_action(action_info: ActionInfo) -> void:
	match action_info.action.kind:
			Helpers.ActionKind.ATTACK:
				var attacker: Node2D
				var target: Node2D
				var victory_function: Callable
				match action_info.action.target:
					Helpers.GigaTarget.MECHAZORD:
						#print("Attack from kaiju")
						attacker = kaiju
						target = mechazord
						victory_function = kaiju_victory
						
					Helpers.GigaTarget.KAIJU:
						#print("Attack from mechazord")
						attacker = mechazord
						target = kaiju
						victory_function = mechazord_victory
						
						
				var target_body_part_index = attacker.next_body_part_index_to_attack(target)
				# print(name + " dealt " + str(damage) + " damage to " + str(target.name))
				var old_shield: float = target.shield
				target.damage_body_part(target_body_part_index, action_info.action.amount, action_info.action.pierces)
				var is_valid_condition := \
					action_info.action.condition_kind != Helpers.Condition.NONE && \
					action_info.action.lasting_time_secs > 0.0 
				#TODO: Remove shield clause once more conditions are added that can occur with shield on
				if is_valid_condition && (action_info.action.amount > old_shield || action_info.action.pierces):
					target.apply_condition(
						action_info.action.condition_kind, 
						target_body_part_index, 
						action_info.action.lasting_time_secs
					)
					if action_info.action.condition_kind == Helpers.Condition.RESTRAINED:
						var attacker_body_parts = attacker.get_node("BodyParts")
						var attacking_body_part_index: int = 0
						for i in range(1, attacker_body_parts.get_child_count()):
							if attacker_body_parts.get_child(i).name == action_info.source_body_part.name:
								attacking_body_part_index = i
								break
						
						attacker.apply_condition(
							action_info.action.condition_kind, 
							attacking_body_part_index, 
							action_info.action.lasting_time_secs
						)
					
				var num_vitals_left_on_target := len(target.body_parts.get_children().filter(
					func(body_part) -> bool: return Helpers.body_part_is_vital(body_part.kind) && body_part.hp > 0
				))
				if num_vitals_left_on_target == 0:
					victory_function.call()
				
			Helpers.ActionKind.REPAIR:
				#TODO: Allow for Kaiju healing if need be
				assert(action_info.action.target == Helpers.GigaTarget.MECHAZORD)
				mechazord.repair_body_part(action_info.action.amount, action_info.action.body_part)
				
			Helpers.ActionKind.SHIELD_GAIN:
				match action_info.action.target:
					Helpers.GigaTarget.MECHAZORD:
						mechazord.gain_shield(action_info.action.amount)
					Helpers.GigaTarget.KAIJU:
						kaiju.gain_shield(action_info.action.amount)
						
			Helpers.ActionKind.REINFORCE_SHIELD:
				match action_info.action.target:
					Helpers.GigaTarget.MECHAZORD:
						mechazord.reinforce_shield(action_info.action.amount)
					Helpers.GigaTarget.KAIJU:
						kaiju.reinforce_shield(action_info.action.amount)
						
			Helpers.ActionKind.BOOST_REPAIR:
				match action_info.action.target:
					Helpers.GigaTarget.MECHAZORD:
						mechazord.boost_repair(action_info.action.multiplier, action_info.action.lasting_time_secs)
					Helpers.GigaTarget.KAIJU:
						kaiju.boost_repair(action_info.action.multiplier, action_info.action.lasting_time_secs)
