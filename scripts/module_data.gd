extends Resource
class_name ModuleData

@export_range(1.0, 500000.0, 1.0, "or_greater", "hide_slider") var charge_capacity: float

func _init(charge_capacity = 100.0):
	self.charge_capacity = charge_capacity
