extends Node2D

@export var modules: Array[ModuleData]

@onready var battle: Node2D = %Battle
@onready var hp_display_temp: Label = $HPDisplay_TEMP
@onready var shield_display_temp: Label = $ShieldDisplay_TEMP

var hp: float = 500.0
var shield: float = 200.0

var charges: Array[float]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in range(len(modules)):
		charges.append(0.0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	assert(len(charges) == len(modules))
	
	for i in range(len(charges)):
		charges[i] += Helpers.KAIJU_DEFAULT_CHARGE_PER_SEC * delta
		
		if charges[i] >= modules[i].charge_capacity:
			battle.queue_action_from_module(modules[i])
			charges[i] = 0.0  
	
	hp_display_temp.text = "HP - " + str(hp)
	shield_display_temp.text = "Shield - " + str(shield)
