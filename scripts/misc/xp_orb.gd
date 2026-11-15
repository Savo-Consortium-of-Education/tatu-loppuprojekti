class_name XPOrb
extends Area2D

@export var xp_value: float = 5.0
@export var attraction_radius: float = 100.0
@export var attraction_speed: float = 250.0

var target: Player = null

func _on_ready() -> void:
    if not multiplayer.is_server():
        return
        
    monitoring = true
    body_entered.connect(_on_body_entered)
    
func _physics_process(delta: float) -> void:
    if not multiplayer.is_server():
        return

    if not is_valid_target(target):
        target = _find_closest_player()

    if target == null:
        return

    global_position = global_position.move_toward(
        target.global_position,
        attraction_speed * delta
    )

func is_valid_target(player: Player) -> bool:
    if not is_instance_valid(player):
        return false

    return (
        not player.is_dead
        and player.is_in_group("players")
        and global_position.distance_squared_to(player.global_position) < attraction_radius * attraction_radius
    )
 
func _find_closest_player() -> Player:
    var closest_player: Player = null
    var closest_distance_squared := attraction_radius * attraction_radius

    for node in get_tree().get_nodes_in_group("players"):
        var player := node as Player
        if player == null or player.is_dead:
            continue

        var distance_squared := global_position.distance_squared_to(player.global_position)
        if distance_squared < closest_distance_squared:
            closest_distance_squared = distance_squared
            closest_player = player

    return closest_player
    
func _on_body_entered(body: Node2D) -> void:
    if not multiplayer.is_server():
        return
        
    if body is Player:
        collect(body)

func collect(player: Player) -> void:
    if not multiplayer.is_server():
        return
    
    SaveManager.add_run_stat(
        player.get_multiplayer_authority(),
        SaveManager.Stat.XP_COLLECTED,
        xp_value
    )
    
    player.gain_xp(xp_value)
    queue_free()
