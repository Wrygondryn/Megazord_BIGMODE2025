extends Node2D

@export_range(0.0, 1000.0, 1.0, "or_greater", "hide_slider") var shield: float = 200.0

@onready var body_parts: Node2D = $BodyParts
@onready var shield_display_temp: Label = $ShieldDisplay_TEMP
@onready var reinforced_shield_display_temp: Label = $ReinforcedShieldDisplay_TEMP
@onready var one_second_timer: Timer = $OneSecondTimer

var reinforced_shield: float = 0.0


signal victory

func damage_target(target: Node2D, damage: float, pierces: bool) -> void:
	# print(name + " dealt " + str(damage) + " damage to " + str(target.name))
	
	var shield_damage = min(target.shield if !pierces else target.reinforced_shield, damage)
	target.shield = max(target.shield - shield_damage, 0.0)
	if pierces:
		target.reinforced_shield = max(target.reinforced_shield - shield_damage, 0.0)
	
	var shield_to_compare = target.shield if !pierces else target.reinforced_shield
	if shield_to_compare < damage:
		var valid_target_indices = []
		for i in range(target.body_parts.get_child_count()):
			if target.body_parts.get_child(i).hp > 0.0:
				valid_target_indices.append(i)
		
		if len(valid_target_indices) == 0: 
			victory.emit()
			return
			
		var body_part_index = valid_target_indices[randi_range(0, len(valid_target_indices) - 1)]
		
		var hp_damage = damage - shield_damage
		var body_part_hp = target.body_parts.get_child(body_part_index).hp
		target.body_parts.get_child(body_part_index).hp = max(body_part_hp - hp_damage, 0.0)

func repair_body_part(heal: float, body_part_kind: Helpers.BodyPart):
	#TODO: Properly handle BodyPart.ANY
	if body_part_kind == Helpers.BodyPart.ANY: return
	#assert(body_part != Helpers.BodyPart.ANY)
	#print("Healed %.0f of %d's HP" % [heal, body_part])
	
	for i in range(body_parts.get_child_count()):
		var body_part = body_parts.get_child(i)
		if body_part.kind == body_part_kind:
			body_part.hp = min(body_part.max_hp, body_part.hp + heal)

func gain_shield(shield_gained: float):
	shield += shield_gained

func reinforce_shield(shield_reinforced: float):
	reinforced_shield = min(reinforced_shield + shield_reinforced, shield)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	shield = max(shield * (1.0 - Helpers.SHIELD_DRAIN_FRAC_PER_SEC * delta), 0.0)
	if shield < reinforced_shield:
		reinforced_shield = shield 
	
	shield_display_temp.text = "Shield - %.0f" % shield
	reinforced_shield_display_temp.text = "Reinforced - %.0f" % reinforced_shield
