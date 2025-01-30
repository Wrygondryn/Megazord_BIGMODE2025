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
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if game_over: return
	
	#TODO: Wait until animation of currently executed action is complete until processing the next
	#NOTE: Mechazord and Kaiju actions can happen simultaneously, so make sure to check for that
	for action in action_queue:
		match action.target:
			ModuleData.ActionTarget.MECHAZORD:
				apply_damage(mechazord, action.damage)
			ModuleData.ActionTarget.KAIJU:
				apply_damage(kaiju, action.damage)
	action_queue.clear()
	
	if mechazord.hp <= 0.0:
		mechazord.hp = 0.0
		print("You Lose!")
		game_over = true
		
	if kaiju.hp <= 0.0:
		kaiju.hp = 0.0
		print("You Win!")
		game_over = true


#TODO: Move into mechazord/kaiju script?
func apply_damage(target: Node2D, damage: float) -> void:
	var shield_damage = min(target.shield, damage)
	var hp_damage = damage - shield_damage
	target.shield = max(target.shield - shield_damage, 0.0)
	target.hp = max(target.hp - hp_damage, 0.0)
