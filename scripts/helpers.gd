extends Node

enum ActionKind {
	ATTACK,
	REPAIR,
	SHIELD_GAIN,
	REINFORCE_SHIELD,
	BOOST_REPAIR
}

enum GigaTarget { 
	MECHAZORD,
	KAIJU
}

#TODO: This is problematic as different mechazoids/kaijus can have different or even repeating body parts
#(e.g., Ghidora heads, Godzilla tail). Right now there are several ways I can think to solve this:
# - Store every unique body part across all kaijus/mechs. Works but janky and a lot of typing.
# - Get body parts via node retrieval. Though this raises the question of how that is stored in ModuleData.
# - Have this only apply to healing, and use alternative method for damage (e.g., the previous dot point)
enum BodyPart {
	HEAD,
	LEFT_ARM,
	RIGHT_ARM,
	TORSO,
	PELVIS,
	LEFT_LEG,
	RIGHT_LEG,
	TAIL,
	ANY
}

enum Condition {
	RESTRAINED,
	NONE
}

#NOTE: This is just here to combine buffs and condtions pretty much
enum Modifier {
	BOOSTED_REPAIR,
	RESTRAINED
}

const MAX_CHARGE_PER_SEC = 100
const CHARGE_DRAIN_PER_SEC = 2.0
const KAIJU_DEFAULT_CHARGE_PER_SEC = 15
const SHIELD_DRAIN_FRAC_PER_SEC = 0.1
const AVOID_VITALS_WEIGHT = 4.0 #NOTE: The higher this is, the less likely vitals are to be hit
const SHIELD_BAR_BACKGROUND_COLOUR = Color.WEB_GRAY

const MIN_VOLUME_DB = -24.0
const MAX_VOLUME_DB = 6.0
const IMPACT_PITCH_RANGE_SEMITONES = 3
const SHIELD_GAIN_PITCH_RANGE_SEMITONES = 2
const REPAIR_PITCH_RANGE_SEMITONES = 2
const REINFORCE_SHIELD_PITCH_RANGE_SEMITONES = 1

const MODIFIER_DISPLAY_X_DELTA = 1.0


static func rand_choice_ps(ps: Array[float]) -> int:
	assert(is_equal_approx(ps.reduce(func (acc: float, x: float) -> float: return acc + x, 0.0), 1.0))
	
	var r := randf()
	var result: int = 0
	while r > ps[result]:
		r -= ps[result]
		result += 1
		
	return result

static func semitones_to_scale(num_semitones: int) -> float:
	return pow(pow(2, 1.0 / 12.0), num_semitones)

static func body_part_is_vital(body_part: BodyPart) -> bool:
	return body_part == BodyPart.HEAD || body_part == BodyPart.TORSO
