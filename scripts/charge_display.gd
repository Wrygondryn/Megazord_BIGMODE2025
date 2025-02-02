extends Node2D

@export var module: Node

@onready var charge_bar: Sprite2D = $ChargeBar
@onready var label:Label = $Label

var initial_charge_bar_transform: Transform2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	initial_charge_bar_transform = charge_bar.transform
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var frac_charged = module.charge / module.data.charge_capacity
	charge_bar.transform = initial_charge_bar_transform.scaled(Vector2(frac_charged, 1.0))
	var initial_width = charge_bar.texture.get_width() * initial_charge_bar_transform.get_scale().x * transform.get_scale().x
	var new_width = initial_width * frac_charged
	charge_bar.global_position.x = transform.origin.x - (initial_width - new_width) / 2.0
	label.text = str(floor(module.data.charge_capacity - module.charge))
