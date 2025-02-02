extends Node3D
class_name Kaiju3D
		

# const MAX_FOCUSED_ATTACKS := 6
const MODIFIER_COOLDOWN_DISPLAY_SCENE = preload("res://prefabs/battle_scene/modifier_cooldown_display.tscn")

@export_range(0.0, 1000.0, 1.0, "or_greater", "hide_slider") var shield: float = 200.0
@export var shield_colour: Color
@export var reinforced_shield_colour: Color
#TODO: Reintroduce this if we want modules that are separate from body parts
#@export var extra_modules: Array[ModuleData]

@onready var body_parts: Array[BodyPart3D];
@onready var modifiers: Node3D = $Modifiers
@onready var shield_display_temp: Label3D = $ShieldDisplay_TEMP
@onready var reinforced_shield_display_temp: Label3D = $ReinforcedShieldDisplay_TEMP
@onready var boost_repair_timer: Timer = $BoostRepairTimer
@onready var shield_bar: Sprite3D = $ShieldBar
@onready var battle: Node3D = %Battle3D

@onready var body_impact_sfx: AudioStreamPlayer = $BodyImpactSFX
@onready var shield_impact_sfx: AudioStreamPlayer = $ShieldImpactSFX
@onready var shield_gain_sfx: AudioStreamPlayer = $ShieldGainSFX
@onready var shield_reinforce_sfx: AudioStreamPlayer = $ShieldReinforceSFX


var reinforced_shield: float = 0.0
var repair_multiplier: float = 1.0
#var num_focused_attacks := 0
#var focused_body_part_index := 0


#NOTE: This is just for testing purposes
func next_vital_index_to_attack(target: Node3D) -> int:
	for i in range(len(target.body_parts)):
		var body_part = target.body_parts[i]
		if body_part.hp > 0.0 && Helpers.body_part_is_vital(body_part.kind):
			return i
	
	assert(false)
	return -1

func next_body_part_index_to_attack(target: Node3D, body_part_kind: Helpers.BodyPart) -> int:
	var valid_target_indices = []
	var num_vitals: int = 0
	for i in range(len(target.body_parts)):
		var body_part = target.body_parts[i]
		if body_part.hp > 0.0 && (body_part.kind == body_part_kind || body_part_kind == Helpers.BodyPart.ANY):
			valid_target_indices.append(i)
			num_vitals += int(Helpers.body_part_is_vital(body_part.kind))

	#NOTE: There are situations where this can happen (e.g.
	if len(valid_target_indices) == 0:			
		print("no valid targets")
		return -1
		
	var valid_target_ps: Array[float] = []
		
	if body_part_kind == Helpers.BodyPart.ANY:
		var prob_of_vitals := float(num_vitals) / float(len(valid_target_indices))
		if num_vitals < len(valid_target_indices):
			prob_of_vitals /= Helpers.AVOID_VITALS_WEIGHT
	 
		var prob_of_non_vitals := 1.0 - prob_of_vitals 
		for body_part_index in valid_target_indices:
			var is_vital := Helpers.body_part_is_vital(target.body_parts[body_part_index].kind)
			var prob_of_like_part = prob_of_vitals if is_vital else prob_of_non_vitals
			var num_like_parts := num_vitals if is_vital else len(valid_target_indices) - num_vitals		
			valid_target_ps.append(prob_of_like_part / float(num_like_parts))
	else:
		for _i in range(len(valid_target_indices)):
			valid_target_ps.append(1.0 / float(len(valid_target_indices)))
	
	assert(len(valid_target_ps) == len(valid_target_indices))
	return valid_target_indices[Helpers.rand_choice_ps(valid_target_ps)]
	
	
	#AI PLAN/PSEUDOCODE:
	# - Pick the body part with the least HP and focus it
	# - When either the body part is down, or after 6 attacks, focus on the next weakest body part
	#
	#var focused_body_part_hp = target.body_parts[focused_body_part_index].hp
	#
	#var result := focused_body_part_index
	#if num_focused_attacks == 0 || focused_body_part_hp == 0.0:
	#	for i in range(1, len(target.body_parts)):
	#		var current_hp = target.body_parts[i].hp
	#		if current_hp != 0.0:
	#			if result == -1:
	#				result = i
	#			else: 
	#				var min_hp = target.body_parts[result].hp
	#				if current_hp > min_hp:
	#					result = i
	#					
	#	num_focused_attacks = (num_focused_attacks + 1) % MAX_FOCUSED_ATTACKS
	#				
	#focused_body_part_index = result
	#return result

func damage_body_part(body_part_index: int, damage: float, pierces: bool) -> void:
	var shield_damage = min(shield if !pierces else reinforced_shield, damage)
	shield = max(shield - shield_damage, 0.0)
	if pierces:
		reinforced_shield = max(reinforced_shield - shield_damage, 0.0)
	
	var impact_sfx = shield_impact_sfx
	
	var shield_to_compare = shield if !pierces else reinforced_shield
	if shield_to_compare == 0.0:
		var hp_damage = damage - shield_damage
		var body_part = body_parts[body_part_index]
		body_part.hp = max(body_part.hp - hp_damage, 0.0)
		
		impact_sfx = body_impact_sfx
	
	var pitch_range_max := Helpers.semitones_to_scale(Helpers.IMPACT_PITCH_RANGE_SEMITONES)
	impact_sfx.pitch_scale = randf_range(1 / pitch_range_max, pitch_range_max) 
	impact_sfx.play()

func repair_body_part(heal: float, body_part_kind: Helpers.BodyPart):
	#TODO: Properly handle BodyPart.ANY
	if body_part_kind == Helpers.BodyPart.ANY: return
	#assert(body_part != Helpers.BodyPart.ANY)
	#print("Healed %.0f of %d's HP" % [heal, body_part])
	
	for i in range(len(body_parts)):
		var body_part = body_parts[i]
		if body_part.kind == body_part_kind:
			body_part.hp = min(body_part.max_hp, body_part.hp + heal * repair_multiplier)

func gain_shield(shield_gained: float):
	shield += shield_gained
	
	var pitch_range_max := Helpers.semitones_to_scale(Helpers.SHIELD_GAIN_PITCH_RANGE_SEMITONES)
	shield_gain_sfx.pitch_scale = randf_range(1 / pitch_range_max, pitch_range_max) 
	shield_gain_sfx.play()

func reinforce_shield(shield_reinforced: float):
	reinforced_shield = min(reinforced_shield + shield_reinforced, shield)
	
	var pitch_range_max := Helpers.semitones_to_scale(Helpers.REINFORCE_SHIELD_PITCH_RANGE_SEMITONES)
	shield_reinforce_sfx.pitch_scale = randf_range(1 / pitch_range_max, pitch_range_max)
	shield_reinforce_sfx.play()

func apply_condition(condition: Helpers.Condition, body_part_index: int, time_length_secs: float):
	assert(time_length_secs > 0.0 && condition != Helpers.Condition.NONE)
	
	var body_part = body_parts[body_part_index]
	body_part.condition = condition
	body_part.condition_timer.wait_time = time_length_secs
	body_part.condition_timer.start()
	
	#NOTE: Ideally this would be more generalised but for now this works
	if condition == Helpers.Condition.RESTRAINED:
		display_modifier_cooldown(Helpers.Modifier.RESTRAINED, time_length_secs)

func boost_repair(multiplier: float, time_length_secs: float):
	repair_multiplier = multiplier
	boost_repair_timer.wait_time = time_length_secs
	boost_repair_timer.start()
	
	display_modifier_cooldown(Helpers.Modifier.BOOSTED_REPAIR, time_length_secs)


func _ready():
	for body_part in $BodyParts.get_children():
		if body_part is BodyPart3D:
			body_parts.append(body_part);
		for module in body_part.modules.get_children(): 
			module.charge_rate = Helpers.KAIJU_DEFAULT_CHARGE_PER_SEC
		
		body_part.action_ready.connect(_on_body_part_action_ready)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void: 
	shield = max(shield * (1.0 - Helpers.SHIELD_DRAIN_FRAC_PER_SEC * delta), 0.0)
	if shield < reinforced_shield:
		reinforced_shield = shield 
	
	if boost_repair_timer.is_stopped():
		repair_multiplier = 1.0
	
	shield_display_temp.text = "Shield - %.0f" % shield
	reinforced_shield_display_temp.text = "Reinforced - %.0f" % reinforced_shield
	
	#NOTE: By default, Gradient starts with 2 points
	var shield_gradient := Gradient.new()
	shield_gradient.interpolation_mode = Gradient.GRADIENT_INTERPOLATE_CONSTANT
	shield_gradient.add_point(1.0, Helpers.SHIELD_BAR_BACKGROUND_COLOUR)
	shield_gradient.set_color(0, reinforced_shield_colour)
	shield_gradient.set_color(1, shield_colour)
	#TODO: Calculate this max
	shield_gradient.set_offset(1, reinforced_shield / 300.0)
	shield_gradient.set_offset(2, shield / 300.0)
	
	var shield_texture := GradientTexture1D.new()
	shield_texture.gradient = shield_gradient
	shield_texture.width = shield_bar.region_rect.size.x
	
	shield_bar.texture = shield_texture

func _on_body_part_action_ready(body_part: Node3D, action: Action, animation: StringName):
	battle.queue_action(Helpers.GigaTarget.KAIJU, body_part, action, animation)
	
	
func display_modifier_cooldown(modifier: Helpers.Modifier, cooldown_secs: float):	
	for cooldown_display in modifiers.get_children():
		if cooldown_display.current_modifier == modifier:
			cooldown_display.start_timed_event(modifier, cooldown_secs)
			return
	
	var new_modifier_cooldown_display = MODIFIER_COOLDOWN_DISPLAY_SCENE.instantiate()
	modifiers.add_child(new_modifier_cooldown_display)
	new_modifier_cooldown_display.global_position = modifiers.global_position
	
	new_modifier_cooldown_display.position.z -= Helpers.MODIFIER_DISPLAY_X_DELTA * (modifiers.get_child_count() - 1)
	new_modifier_cooldown_display.start_timed_event(modifier, cooldown_secs)
