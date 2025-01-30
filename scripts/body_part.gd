extends Node2D

@export var kind: Helpers.BodyPart = Helpers.BodyPart.ANY
@export_range(10.0, 10000.0, 1.0, "or_greater", "hide_slider") var max_hp: float

@onready var hp_display_temp: Label = $HPDisplay_TEMP

var hp: float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hp = max_hp


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	hp_display_temp.text = "HP - %.0f" % hp
