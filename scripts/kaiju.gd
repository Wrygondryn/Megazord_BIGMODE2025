extends Node2D

@export var modules: Array[ModuleData]
@export_range(0.0, 1000.0, 1.0, "or_greater", "hide_slider") var shield: float = 200.0

@onready var battle: Node2D = %Battle
@onready var body_parts: Node2D = $BodyParts
@onready var shield_display_temp: Label = $ShieldDisplay_TEMP

var hp: float = 500.0

var charges: Array[float]


signal victory

func damage_target(target: Node2D, damage: float, pierces: bool) -> void:
	# print(name + " dealt " + str(damage) + " damage to " + str(target.name))
	
	var shield_damage = min(target.shield, damage) if !pierces else 0.0
	target.shield = max(target.shield - shield_damage, 0.0)
	
	if target.shield < damage || pierces:
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

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in range(len(modules)):
		charges.append(0.0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	assert(len(charges) == len(modules))
	
	shield = max(shield * (1.0 - Helpers.SHIELD_DRAIN_FRAC_PER_SEC * delta), 0.0) 
	
	for i in range(len(charges)):
		charges[i] += Helpers.KAIJU_DEFAULT_CHARGE_PER_SEC * delta
		
		if charges[i] >= modules[i].charge_capacity:
			battle.queue_action(Action.from_module_data(modules[i]))
			charges[i] = 0.0  
	
	shield_display_temp.text = "Shield - %.0f" % shield
