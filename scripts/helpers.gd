extends Node

enum ActionKind {
	ATTACK,
	REPAIR
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
	ANY
}

const MAX_CHARGE_PER_SEC = 50
const KAIJU_DEFAULT_CHARGE_PER_SEC = 25
const DEFAULT_SHIELD_DRAIN_PER_SEC = 10
