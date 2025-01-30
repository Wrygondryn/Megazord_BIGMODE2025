extends Node2D

#TODO: Add on additional properties when need be like condition, animation, etc.
class Action:
	var damage: float
	var target: ModuleData.ActionTarget
	
	func _init(damage: float, target: ModuleData.ActionTarget):
		self.damage = damage
		self.target = target
	
	
@onready var mechazord: Node2D = $Mechazord
@onready var kaiju: Node2D = $Kaiju

var game_over := false
var action_queue: Array[Action]


func queue_action_from_module(module: ModuleData):
	action_queue.append(Action.new(module.damage, module.target))


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
			ModuleData.ActionTarget.MECHAZORD:
				kaiju.damage_target(mechazord, action.damage)
			ModuleData.ActionTarget.KAIJU:
				mechazord.damage_target(kaiju, action.damage)
	action_queue.clear()

func _on_kaiju_victory():
	print("You Lose!")
	game_over = true
	
func _on_mechazord_victory():
	print("You Win!")
	game_over = true
