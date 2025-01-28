extends Node2D

@onready var line: Line2D = $Line2D
@onready var sprite: Sprite2D = $Sprite2D

var connected_socket: Node2D = null
var end_point := Vector2(0.0, 0.0) 


func radius() -> float:
	return sprite.transform.get_scale().x * sprite.texture.get_width() / 2.0

func set_end_point(global_point: Vector2):
	end_point = global_point

func _ready():
	line.points[1] = to_local(end_point)

# Called when the node enters the scene tree for the first time.
func _process(delta: float) -> void:
	assert(len(line.points) == 2)
	line.points[1] = to_local(end_point)
	
