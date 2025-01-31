extends Node2D

@export_range(0.0, 1000.0, 1.0, "or_greater", "hide_slider") var shield: float = 200.0

@onready var body_parts: Node2D = $BodyParts
@onready var shield_display_temp: Label = $ShieldDisplay_TEMP
@onready var reinforced_shield_display_temp: Label = $ReinforcedShieldDisplay_TEMP
@onready var battle: Node2D = %Battle

var reinforced_shield: float = 0.0


signal victory

func next_body_part_index_to_attack(target: Node2D) -> int:
	var valid_target_indices = []
	for i in range(target.body_parts.get_child_count()):
		if target.body_parts.get_child(i).hp > 0.0:
			valid_target_indices.append(i)
				
	if len(valid_target_indices) == 0: 
		return -1
		
	return valid_target_indices[randi_range(0, len(valid_target_indices) - 1)]

func damage_body_part(body_part_index: int, damage: float, pierces: bool) -> void:
	var shield_damage = min(shield if !pierces else reinforced_shield, damage)
	shield = max(shield - shield_damage, 0.0)
	if pierces:
		reinforced_shield = max(reinforced_shield - shield_damage, 0.0)
	
	var shield_to_compare = shield if !pierces else reinforced_shield
	if shield_to_compare < damage:
		var hp_damage = damage - shield_damage
		var body_part = body_parts.get_child(body_part_index)
		body_part.hp = max(body_part.hp - hp_damage, 0.0)

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

func apply_condition(condition: Helpers.Condition, body_part_index: int, time_length_secs: float):
	var body_part = body_parts.get_child(body_part_index)
	body_part.condition = condition
	body_part.condition_timer.wait_time = time_length_secs
	body_part.condition_timer.start()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for body_part in body_parts.get_children():
		body_part.action_ready.connect(_on_body_part_action_ready)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	shield = max(shield * (1.0 - Helpers.SHIELD_DRAIN_FRAC_PER_SEC * delta), 0.0)
	if shield < reinforced_shield:
		reinforced_shield = shield 
	
	shield_display_temp.text = "Shield - %.0f" % shield
	reinforced_shield_display_temp.text = "Reinforced - %.0f" % reinforced_shield
	
func _on_body_part_action_ready(action: Action):
	battle.queue_action(action)
