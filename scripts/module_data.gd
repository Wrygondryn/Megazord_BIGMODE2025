extends Resource
class_name ModuleData


#NOTE: Ideally I'd just store an Action variable here, but unfortunately that's not possible *sigh* 
#TODO: Have some sort of subclassing to separate stats that don't go together (e.g., damage and
#heal). It's not important rn but might be in the future
@export var action_kind: Helpers.ActionKind
@export_range(0.0, 1000.0, 1.0, "or_greater", "hide_slider") var damage: float
@export_range(0.0, 1000.0, 1.0, "or_greater", "hide_slider") var heal: float
@export var pierces: bool
@export var giga_target: Helpers.GigaTarget
@export var target_body_part: Helpers.BodyPart

@export_range(1.0, 500000.0, 1.0, "or_greater", "hide_slider") var charge_capacity: float

func _init(
	action_kind := Helpers.ActionKind.ATTACK,
	charge_capacity = 100.0, 
	damage := 0.0,
	heal := 0.0,
	pierces := false, 
	giga_target := Helpers.GigaTarget.KAIJU, 
	target_body_part := Helpers.BodyPart.ANY
):
	self.action_kind = action_kind
	self.damage = damage
	self.heal = heal
	self.pierces = pierces
	self.giga_target = giga_target
	self.target_body_part = target_body_part
	
	self.charge_capacity = charge_capacity
