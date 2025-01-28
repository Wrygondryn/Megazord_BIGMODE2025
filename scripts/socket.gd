extends Node2D

@onready var sprite: Sprite2D = $Sprite2D

var plugged := false


func radius():
	return sprite.transform.get_scale().x * sprite.texture.get_width() / 2.0
	
#TODO: Add more stuff when need be, right now this is just so that you can't put the same jack into one socket
func plug():
	plugged = true
	
