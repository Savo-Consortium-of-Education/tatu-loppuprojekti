extends MultiplayerSpawner

func _ready() -> void:
    spawn_function = spawn_projectile_replica

func spawn_projectile_replica(data: Dictionary) -> Node:
    var projectile = preload(
        "res://scenes/projectiles/enemy_bolt.tscn"
    ).instantiate() as EnemyProjectile

    projectile.position = data["position"]
    projectile.direction = data["direction"]
    projectile.speed = data["speed"]
    projectile.damage = data["damage"]

    return projectile
