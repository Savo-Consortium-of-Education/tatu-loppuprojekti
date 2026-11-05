class_name EnemyProjectile extends Area2D

@export var speed: float = 250.0
@export var damage: float = 10.0
@export var lifetime: float = 5.0

var direction: Vector2 = Vector2.ZERO

func _ready() -> void:
    body_entered.connect(_on_body_entered)
    if multiplayer.is_server():
        await get_tree().create_timer(lifetime).timeout
        if is_instance_valid(self):
            queue_free()

func _physics_process(delta: float) -> void:
    if not multiplayer.is_server():
        return
    global_position += direction * speed * delta

func _on_body_entered(body: Node2D) -> void:
    if not multiplayer.is_server():
        return

    if body is Player:
        body.take_damage(damage)
        queue_free()
