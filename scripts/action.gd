class_name Action

#TODO: Add on additional properties when need be like condition, animation, etc.
var kind: Helpers.ActionKind
var damage: float
var heal: float
var pierces: bool
var target: Helpers.GigaTarget
var body_part: Helpers.BodyPart
		
func _init(
	kind: Helpers.ActionKind, 
	damage: float, 
	heal: float, 
	pierces: bool,
	target: Helpers.GigaTarget, 
	body_part: Helpers.BodyPart
):
	self.kind = kind
	self.damage = damage
	self.heal = heal
	self.pierces = pierces
	self.target = target
	self.body_part = body_part

#func attack(damage: float, target: ModuleData.GigaTarget):
#	return _init(damage, 0.0, target, ModuleData.BodyPart.ANY)
#
#func repair(heal: float, target: ModuleData.GigaTarget, body_part: ModuleData.BodyPart):
#	return _init(0.0, heal, target, body_part)

static func from_module_data(module: ModuleData):
	return Action.new(
		module.action_kind, 
		module.damage, 
		module.heal, 
		module.pierces, 
		module.giga_target, 
		module.target_body_part
	)
