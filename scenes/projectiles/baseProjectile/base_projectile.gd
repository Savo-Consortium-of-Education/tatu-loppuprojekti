class_name Projectile extends Area2D

@export var direction: Vector2 = Vector2.RIGHT
@export var speed: float = 600.0
@export var damage: float = 10.0
@export var shooter: Node2D

func _ready() -> void:
    body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
    global_position += direction * speed * delta
    rotation = direction.angle() + GameManager.SPRITE_ROTATION_OFFSET

func _on_body_entered(body: Node2D) -> void:
    if body == shooter:
        return

    if body.has_method("take_damage"):
        body.take_damage(damage)
        queue_free()
