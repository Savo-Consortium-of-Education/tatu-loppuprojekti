class_name Projectile extends Area2D

@export var direction: Vector2 = Vector2.RIGHT
@export var speed: float = 600.0
@export var damage: float = 10.0
@export var shooter: Node2D

func _ready() -> void:
    add_to_group("projectiles")
    body_entered.connect(_on_body_entered)
    area_entered.connect(_on_area_entered)

func _physics_process(delta: float) -> void:
    global_position += direction * speed * delta
    rotation = direction.angle() + GameManager.SPRITE_ROTATION_OFFSET

func _on_body_entered(body: Node2D) -> void:
    if body == shooter:
        return
        
    # don't harm other enemies with their projectiles
    if body.is_in_group("enemies") and shooter.is_in_group("enemies"):
        return

    if body.has_method("take_damage"):
        body.take_damage(damage)
        queue_free()

func _on_area_entered(area: Area2D) -> void:
    if not area.is_in_group("projectiles"):
        return

    # player's projectile hits enemy's projectile
    if not shooter.is_in_group("enemies") and area.shooter != null:
        if area.shooter.is_in_group("enemies"):
            area.queue_free()
            queue_free()
