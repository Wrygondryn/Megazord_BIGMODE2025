extends Node2D
	
@onready var mechazord: Node2D = $Mechazord
@onready var kaiju: Node2D = $Kaiju

var game_over := false
var action_queue: Array[Action]


func queue_action(action: Action):
	action_queue.append(action)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	mechazord.victory.connect(_on_mechazord_victory)
	kaiju.victory.connect(_on_kaiju_victory)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if game_over: return
	
	#TODO: Wait until animation of currently executed action is complete until processing the next
	#NOTE: Mechazord and Kaiju actions can happen simultaneously, so make sure to check for that
	for action in action_queue:
		match action.target:
			Helpers.GigaTarget.MECHAZORD:
				kaiju.damage_target(mechazord, action.damage)
				#TODO: This line is janky af, refactor action/module data to have subclassing
				#(ideally would be tagged union or some sort of algebraic type but to
				#my knowldge unfortunately GDScript doesn't have that)
				mechazord.repair_body_part(action.heal, action.body_part)
			Helpers.GigaTarget.KAIJU:
				mechazord.damage_target(kaiju, action.damage)
	action_queue.clear()

func _on_kaiju_victory():
	print("You Lose!")
	game_over = true
	
func _on_mechazord_victory():
	print("You Win!")
	game_over = true
