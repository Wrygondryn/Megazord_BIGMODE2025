extends Node2D
	
@onready var mechazord: Node2D = $Mechazord
@onready var kaiju: Node2D = $Kaiju

var game_over := false
var action_queue: Array[Action]


func queue_action(action: Action):
	action_queue.append(action)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if game_over: return
	
	#TODO: Wait until animation of currently executed action is complete until processing the next
	#NOTE: Mechazord and Kaiju actions can happen simultaneously, so make sure to check for that when
	#animations get integrated
	for action in action_queue:
		match action.kind:
			Helpers.ActionKind.ATTACK:
				var attacker: Node2D
				var target: Node2D
				var victory_function: Callable
				match action.target:
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
				if target_body_part_index == -1:
					victory_function.call()
				# print(name + " dealt " + str(damage) + " damage to " + str(target.name))
				target.damage_body_part(target_body_part_index, action.amount, action.pierces)
				target.apply_condition(action.condition_kind, target_body_part_index, action.condition_time_secs)
				
			Helpers.ActionKind.REPAIR:
				#TODO: Allow for Kaiju healing if need be
				assert(action.target == Helpers.GigaTarget.MECHAZORD)
				mechazord.repair_body_part(action.amount, action.body_part)
				
			Helpers.ActionKind.SHIELD_GAIN:
				match action.target:
					Helpers.GigaTarget.MECHAZORD:
						mechazord.gain_shield(action.amount)
					Helpers.GigaTarget.KAIJU:
						kaiju.gain_shield(action.amount)
						
			Helpers.ActionKind.REINFORCE_SHIELD:
				match action.target:
					Helpers.GigaTarget.MECHAZORD:
						mechazord.reinforce_shield(action.amount)
					Helpers.GigaTarget.KAIJU:
						kaiju.reinforce_shield(action.amount)
	
	#TODO: Remove once animations are a thing
	action_queue.clear()

func kaiju_victory():
	print("You Lose!")
	game_over = true
	
func mechazord_victory():
	print("You Win!")
	game_over = true
