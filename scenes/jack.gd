extends Node2D

@onready var sprite: Sprite2D = $Sprite2D

#Ideally this would be a constant or some predefined number, but for now I think
#this will work
func radius() -> float:
	return sprite.transform.get_scale().x * sprite.texture.get_width()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print(radius())


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var mouse_pos := get_local_mouse_position()
	var r := radius()
	if transform.get_origin().distance_squared_to(mouse_pos) <= r * r:
		print("Inside")
