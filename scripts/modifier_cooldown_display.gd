extends Node3D

const BOOSTED_REPAIR_SPRITE = preload("res://assets/sprites/dashboard/action_symbols/boostrepair_symbol.png")
const RESTRAINED_SPRITE = preload("res://assets/sprites/dashboard/action_symbols/restrain-arm_claw_symbol.png")

@export var boon_colour: Color
@export var bane_colour: Color

@onready var sprite_3d: Sprite3D = $Sprite3D
@onready var background: TextureRect = $SubViewport/Background
@onready var symbol: TextureRect = $SubViewport/Symbol
@onready var remaining_time_text: Label = $SubViewport/RemainingTimeText
@onready var timer: Timer = $Timer

var initial_position: Vector2
var current_modifier: Helpers.Modifier
var current_time_length_secs: float = 0.0
var should_start_cooldown = false


func start_timed_event(modifier: Helpers.Modifier, time_length_secs: float):
	current_modifier = modifier
	current_time_length_secs = time_length_secs
	should_start_cooldown = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	initial_position = symbol.position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if timer.is_stopped():
		hide()
		
	if should_start_cooldown:
		commence_timing()
		should_start_cooldown = false
		
	var symbol_scale = float(background.texture.get_width()) / float(symbol.texture.get_width())
	symbol.scale = Vector2.ONE * symbol_scale
	symbol.position = initial_position + Vector2.ONE * background.texture.get_width() * (1.0 - symbol_scale) / 2.0
	
	remaining_time_text.text = "%.1f" % timer.time_left

func _on_timer_timeout() -> void:
	queue_free()

#NOTE: This is really only to get around instantiated scenes not calling _ready() by the time we call
#start_timed_event
func commence_timing():
	match current_modifier:
		Helpers.Modifier.BOOSTED_REPAIR:
			background.modulate = boon_colour
			symbol.texture = BOOSTED_REPAIR_SPRITE
		
		Helpers.Modifier.RESTRAINED:
			background.modulate = bane_colour
			symbol.texture = RESTRAINED_SPRITE
	
	timer.wait_time = current_time_length_secs
	timer.start()
	
	show()
