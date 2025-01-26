extends Node2D

@onready var line: Line2D = $Line2D

# Called when the node enters the scene tree for the first time.
func _process(delta: float) -> void:
	assert(len(line.points) == 2)
	line.points[1] = to_local(Vector2(40, -100))
