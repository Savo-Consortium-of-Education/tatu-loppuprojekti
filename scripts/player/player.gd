class_name Player extends CharacterBody2D

@onready var visuals = $Visuals

var player_speed: float = 300.0
var current_hp: int = 3
var current_boost: float = 100
var current_level: int = 0

func _physics_process(delta: float) -> void:
	handle_movement()
	handle_rotation()
	
	move_and_slide()

func handle_movement() -> void:
	var direction := Input.get_vector(
		"move_left",
		"move_right",
		"move_up",
		"move_down"
	)
	velocity = direction * player_speed
	
func handle_rotation() -> void:
	visuals.look_at(get_global_mouse_position())
