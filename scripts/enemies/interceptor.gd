extends Enemy

@export var explosion_radius = 75.0
@export var explosion_damage = 20.0

const explosion_scene: PackedScene = preload("res://scenes/particles/explosion.tscn")

func apply_difficulty_scaling(
    hp_multiplier: float,
    damage_multiplier: float,
    speed_multiplier: float
) -> void:
    super.apply_difficulty_scaling(
        hp_multiplier,
        damage_multiplier,
        speed_multiplier
    )
    explosion_damage *= damage_multiplier

func die(attacker_peer_id: int, hit_direction: Vector2 = Vector2.ZERO) -> void:
    var explosion = explosion_scene.instantiate()
    get_tree().current_scene.add_child(explosion)
    explosion.global_position = global_position
    explosion.restart()
    explosion.emitting = true
    get_tree().create_timer(explosion.lifetime + 0.1).timeout.connect(explosion.queue_free)

    for player in get_tree().get_nodes_in_group("players"):
        var p := player as Player
        if p == null or p.is_dead:
            continue

        var distance: float = global_position.distance_to(p.global_position)
        print("Distance: ", distance)

        if distance >= explosion_radius:
            continue

        p.take_damage(explosion_damage)

    super.die(attacker_peer_id, hit_direction)
