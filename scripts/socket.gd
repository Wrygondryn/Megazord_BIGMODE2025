extends Node2D

@onready var sprite: Sprite2D = $Sprite2D
@onready var charge_display_temp: Label = $ChargeDisplay_TEMP

var connected_jack: Node2D = null


func radius():
	return sprite.transform.get_scale().x * sprite.texture.get_width() / 2.0
