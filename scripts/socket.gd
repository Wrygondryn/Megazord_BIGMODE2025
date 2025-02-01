extends Node2D

@export var module: Module

@onready var sprite: Sprite2D = $Sprite2D
@onready var power_display_temp: Label = $PowerDisplay_TEMP
@onready var plug_in_sfx: AudioStreamPlayer2D = $PlugInSFX
@onready var unplug_sfx: AudioStreamPlayer2D = $UnplugSFX

var connected_jack: Node2D = null


func radius():
	return sprite.transform.get_scale().x * sprite.texture.get_width() / 2.0


func _on_jack_area_area_entered(area: Area2D) -> void:
	plug_in_sfx.play()


func _on_jack_area_area_exited(area: Area2D) -> void:
	unplug_sfx.play()
