class_name XPOrb
extends Area2D

@export var xp_value: float = 5.0

func _on_ready() -> void:
    monitoring = true
    body_entered.connect(_on_body_entered)
    
func _on_body_entered(body: Node2D) -> void:
    if body is Player:
        body.gain_xp(xp_value)
        queue_free()
