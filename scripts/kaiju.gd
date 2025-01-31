extends Node2D
		

@export_range(0.0, 1000.0, 1.0, "or_greater", "hide_slider") var shield: float = 200.0
#TODO: Reintroduce this if we want modules that are separate from body parts
#@export var extra_modules: Array[ModuleData]

@onready var body_parts: Node2D = $BodyParts
@onready var shield_display_temp: Label = $ShieldDisplay_TEMP
@onready var reinforced_shield_display_temp: Label = $ReinforcedShieldDisplay_TEMP
@onready var battle: Node2D = %Battle

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

func gain_shield(shield_gained: float):
	shield += shield_gained

func reinforce_shield(shield_reinforced: float):
	reinforced_shield = min(reinforced_shield + shield_reinforced, shield)

func apply_condition(condition: Helpers.Condition, target_body_part: Helpers.BodyPart, time_length_secs: float):
	for i in range(body_parts.get_child_count()):
		var body_part = body_parts.get_child(i)
		if body_part.kind == target_body_part:
			body_part.condition = condition
			body_part.condition_timer.wait_time = time_length_secs
			body_part.condition_timer.start()
			break


func _ready():
	for body_part in body_parts.get_children():
		for module in body_part.modules.get_children(): 
			module.charge_rate = Helpers.KAIJU_DEFAULT_CHARGE_PER_SEC
		
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
