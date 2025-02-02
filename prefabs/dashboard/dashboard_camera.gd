extends Camera2D

@export var zoom_init:float = 1.01;
@export var look_speed:float = 0.005;
@export var parallax_frame:Sprite2D;
@export var parallax_look_speed:float = 0.03;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.zoom = Vector2(zoom_init,zoom_init);

func _process(delta: float) -> void:
	var mouse_pos := get_global_mouse_position();
	var view_size:Vector2 = get_viewport().size/2;
	mouse_pos.x = max(min(mouse_pos.x, view_size.x), -view_size.x);
	mouse_pos.y = max(min(mouse_pos.y, view_size.y), -view_size.y);
	self.offset = mouse_pos*look_speed;
	parallax_frame.offset = -mouse_pos*parallax_look_speed;

func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_F11:
			if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			else:
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
