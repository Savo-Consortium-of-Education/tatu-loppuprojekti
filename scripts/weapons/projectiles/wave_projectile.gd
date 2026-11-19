extends Projectile

@onready var animation_player := $AnimationPlayer as AnimationPlayer

func _ready() -> void:
    super()
    animation_player.play("attack")
    var timer = Timer.new()
    timer.wait_time = 0.05
    timer.autostart = true
    timer.one_shot = false
    timer.timeout.connect(_check_overlapping_players)
    add_child(timer)

func _physics_process(delta: float) -> void:
    # wave doesn't move, only scales up via animation
    pass

func _check_overlapping_players() -> void:
    if not multiplayer.is_server() or destroyed:
        return
    for body in get_overlapping_bodies():
        if body is Player and shooter_is_enemy:
            body.take_damage(damage)

func finish_wave() -> void:
    if multiplayer.is_server():
        queue_free()
