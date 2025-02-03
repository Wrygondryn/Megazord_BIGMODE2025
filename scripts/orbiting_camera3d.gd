extends Camera3D

@export var orbit_speed:float = 10.0;
@export var orbit_origin:Node3D;

func _ready() -> void:
	self.top_level = false;

func _process(delta: float) -> void:
	self.orbit_origin.rotate(self.orbit_origin.basis.y, delta*orbit_speed);
