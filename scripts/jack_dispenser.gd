extends Node2D

const JACK_SCENE = preload("res://scenes/jack.tscn")

@export_range(1, 10) var power: int = 1
@export var colour: Color = Color.BLACK
@export var jack_sprite_override:Texture2D = null;

@onready var sprite: Sprite2D = $Sprite2D

func new_jack() -> Node2D:
	var new_jack = JACK_SCENE.instantiate()
	new_jack.power = power
	new_jack.set_end_point(global_position)
	new_jack.colour = colour
	new_jack.spritetex_override = jack_sprite_override;
	return new_jack


func _ready():
	sprite.modulate = colour
