extends Node2D

@onready var timer = $Timer
@onready var hud = $Hud

var elapsed_time: int = 0

func _ready() -> void:
	timer.timeout.connect(_on_timer_timeout)
	start_game()

func start_game() -> void:
	elapsed_time = 0
	timer.start()

func _on_timer_timeout() -> void:
	elapsed_time += 1

func end_game() -> void:
	timer.stop()
	GameManager.end_game()
