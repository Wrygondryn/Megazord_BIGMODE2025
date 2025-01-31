extends Node2D

@export var kind: Helpers.BodyPart = Helpers.BodyPart.ANY
@export_range(10.0, 10000.0, 1.0, "or_greater", "hide_slider") var max_hp: float

@onready var modules: Node = $Modules
@onready var hp_display_temp: Label = $HPDisplay_TEMP
@onready var condition_timer: Timer = $ConditionTimer

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
	hp_display_temp.text = "HP - %.0f" % hp

func _on_module_fully_charged(data: ModuleData) -> void:
	action_ready.emit(Action.from_module_data(data))
