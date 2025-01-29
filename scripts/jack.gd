extends Node2D

@export_range(0, 10, 1, "or_greater") var power: int = 1

@onready var line: Line2D = $Line2D
@onready var sprite: Sprite2D = $Sprite2D

var connected_socket: Node2D = null
var end_point := Vector2(0.0, 0.0) 

var colour: Color = Color.BLACK

func radius() -> float:
	return sprite.transform.get_scale().x * sprite.texture.get_width() / 2.0

func set_end_point(global_point: Vector2):
	end_point = global_point

func _ready():
	line.default_color = colour
	line.points[1] = to_local(end_point)

# Called when the node enters the scene tree for the first time.
func _process(delta: float) -> void:
	assert(len(line.points) == 2)
	line.points[1] = to_local(end_point)
	
