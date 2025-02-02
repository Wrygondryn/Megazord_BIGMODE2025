extends Node
class_name Module

@export var data: ModuleData
@export var animation_name: StringName

var charge: float = 0.0
var charge_rate: float = 0.0


signal fully_charged


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if (charge_rate < 0.0): print("hey")
	charge += charge_rate * delta
	
	#TODO: Charge decay
	if charge >= data.charge_capacity:
		fully_charged.emit(data, animation_name)
		charge = 0.0
		
	if charge <= 0.0:
		charge = 0.0
