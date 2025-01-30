extends Node2D

@onready var body_parts: Node2D = $BodyParts
@onready var shield_display_temp: Label = $ShieldDisplay_TEMP

var hp: float = 500.0
var shield: float = 200.0


signal victory

func damage_target(target: Node2D, damage: float) -> void:
	# print(name + " dealt " + str(damage) + " damage to " + str(target.name))
	
	var shield_damage = min(target.shield, damage)
	target.shield = max(target.shield - shield_damage, 0.0)
	
	if target.shield < damage:
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


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	shield = max(shield - Helpers.DEFAULT_SHIELD_DRAIN_PER_SEC * delta, 0.0)
	
	shield_display_temp.text = "Shield - %.0f" % shield
