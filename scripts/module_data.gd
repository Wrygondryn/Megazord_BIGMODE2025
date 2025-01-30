extends Resource
class_name ModuleData

#TODO: Allow for specification of body part?
enum ActionTarget { 
	MECHAZORD,
	KAIJU
}

@export_range(1.0, 500000.0, 1.0, "or_greater", "hide_slider") var charge_capacity: float
@export_range(0.0, 1000.0, 1.0, "or_greater", "hide_slider") var damage: float
@export var target: ActionTarget

func _init(charge_capacity = 100.0, damage := 0.0, target := ActionTarget.KAIJU):
	self.charge_capacity = charge_capacity
	self.damage = damage
	self.target = target
