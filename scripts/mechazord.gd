extends Node2D

@onready var shield_display_temp: Label = $ShieldDisplay_TEMP

var hp: float = 500.0
var shield: float = 200.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	shield = max(shield - Helpers.DEFAULT_SHIELD_DRAIN_PER_SEC * delta, 0.0)
	
	shield_display_temp.text = "Shield - %.0f" % shield
