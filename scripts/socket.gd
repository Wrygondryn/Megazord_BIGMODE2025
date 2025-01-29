extends Node2D

@export var module: Module

@onready var sprite: Sprite2D = $Sprite2D
@onready var power_display_temp: Label = $PowerDisplay_TEMP

var connected_jack: Node2D = null


func radius():
	return sprite.transform.get_scale().x * sprite.texture.get_width() / 2.0
