#REFACTOR PLAN:
# - Have a class SubAction, which purely stores data and has extending classes like Damage, Heal, Condition, 
#   etc.
# - Action is an Array[SubAction] (this allows for stuff like damage + heal, like with a siphoning attack,
#   or damage + condition).
# - Hopefull ModuleData can work with inheritance, else ModuleData may just have to be janky by nature

class_name Action

#TODO: Add on additional properties when need be like condition, animation, etc.
var damage: float
var heal: float
var target: Helpers.GigaTarget
var body_part: Helpers.BodyPart
		
func _init(damage: float, heal: float, target: Helpers.GigaTarget, body_part: Helpers.BodyPart):
	self.damage = damage
	self.heal = heal
	self.target = target
	self.body_part = body_part

#func attack(damage: float, target: ModuleData.GigaTarget):
#	return _init(damage, 0.0, target, ModuleData.BodyPart.ANY)
#
#func repair(heal: float, target: ModuleData.GigaTarget, body_part: ModuleData.BodyPart):
#	return _init(0.0, heal, target, body_part)

static func from_module_data(module: ModuleData):
	return Action.new(module.damage, module.heal, module.giga_target, module.target_body_part)
