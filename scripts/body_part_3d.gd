extends Node3D

@export var kind: Helpers.BodyPart = Helpers.BodyPart.ANY
@export var hp_colour: Color
@export_range(10.0, 10000.0, 1.0, "or_greater", "hide_slider") var max_hp: float

@onready var modules: Node = $Modules
@onready var hp_display_temp: Label3D = $HPDisplay_TEMP
@onready var condition_display_temp: Label3D = $ConditionDisplay_TEMP
@onready var condition_timer: Timer = $ConditionTimer
@onready var hp_bar: Sprite3D = $HPBar

var hp: float
var condition := Helpers.Condition.NONE 

signal action_ready


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hp = max_hp
	for module in modules.get_children():
		module.fully_charged.connect(_on_module_fully_charged)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if condition_timer.is_stopped():
		condition = Helpers.Condition.NONE
	
	hp_display_temp.text = "HP - %.0f" % hp
	if condition != Helpers.Condition.NONE:
		condition_display_temp.text = Helpers.Condition.keys()[condition]
	else:
		condition_display_temp.text = ""
	
	#NOTE: By default, Gradient starts with 2 points
	var hp_gradient := Gradient.new()
	hp_gradient.interpolation_mode = Gradient.GRADIENT_INTERPOLATE_CONSTANT
	hp_gradient.set_color(0, hp_colour)
	hp_gradient.set_offset(1, hp / max_hp)
	hp_gradient.set_color(1, Color.BLACK)
	
	var hp_texture := GradientTexture1D.new()
	hp_texture.gradient = hp_gradient
	hp_texture.width = hp_bar.region_rect.size.x
	
	hp_bar.texture = hp_texture

func _on_module_fully_charged(data: ModuleData) -> void:
	match condition:
		Helpers.Condition.NONE: 
			action_ready.emit(self, Action.from_module_data(data))
		
		Helpers.Condition.RESTRAINED:
			return 
