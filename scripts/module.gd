extends Node2D
class_name Module

@export var module_data: ModuleData

@onready var charge_bar: Sprite2D = $ChargeBar

var charge: float = 0.0
var charge_rate: float = 0.0
var initial_charge_bar_transform: Transform2D

func set_proportional_charge_rate(proportion: float):
	assert(proportion >= 0.0 && proportion <= 1.0)
	charge_rate = Helpers.MAX_CHARGE_PER_SEC * proportion

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	initial_charge_bar_transform = charge_bar.transform
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	charge += charge_rate * delta
	#TODO: Charge decay
	if charge >= module_data.charge_capacity || charge <= 0.0:
		charge = 0.0
	
	var frac_charged = charge / module_data.charge_capacity
	charge_bar.transform = initial_charge_bar_transform.scaled(Vector2(frac_charged, 1.0))
	var initial_width = charge_bar.texture.get_width() * initial_charge_bar_transform.get_scale().x * transform.get_scale().x
	var new_width = initial_width * frac_charged
	charge_bar.global_position.x = transform.origin.x - (initial_width - new_width) / 2.0
