extends MultiplayerSpawner

const DEFAULT_PROJECTILE_SCENE: PackedScene = preload(
    "res://scenes/projectiles/bolt.tscn"
)

func _ready() -> void:
    spawn_function = spawn_projectile_replica

func spawn_projectile_replica(data: Dictionary) -> Node:
    var projectile_scene := DEFAULT_PROJECTILE_SCENE
    var projectile_path: String = data.get("projectile_path", "")
    if not projectile_path.is_empty():
        var selected_scene := load(projectile_path) as PackedScene
        if selected_scene == null:
            push_error("Enemy projectile scene could not be loaded: " + projectile_path)
        else:
            projectile_scene = selected_scene

    var projectile = projectile_scene.instantiate() as Projectile
    if projectile == null:
        push_error("Enemy projectile scene must use the Projectile script")
        return null

    projectile.position = data["position"]
    projectile.direction = data["direction"]
    projectile.speed = data["speed"]
    projectile.damage = data["damage"]
    projectile.shooter = get_node_or_null(
        NodePath(data["shooter_path"])
    ) as Node2D

    return projectile
