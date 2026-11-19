class_name game_object extends Area2D

@export var break_particles_scene: PackedScene

@export_group("xp")
@export var xp_orb_scene = preload("res://scenes/misc/xp_orb.tscn")
@export var xp_chance: float = 0.1
@export var xp_min: float = 1.0
@export var xp_max: float = 3.0

@export_group("powerup")
@export var powerup_chance: float = 0.05
@export var powerup_pool: Array[PackedScene] = [
    preload("res://scenes/powerups/hp_powerup.tscn"),
    preload("res://scenes/powerups/ability_powerup.tscn")
]

@export_group("physics")
@export var base_drift_speed: float = 3.0
@export var drift_randomness: float = 1.0
@export var rotation_speed: float = 0.08
@export var inherited_velocity_multiplier: float = 0.05
@export var max_drift_speed: float = 5.0
@export var sync_interval: float = 0.05

@onready var solid_body: RigidBody2D = $SolidBody
@onready var polygon: Polygon2D = $SolidBody/Polygon2D
@onready var glow_polygon: Polygon2D = $SolidBody/GlowPolygon2D
@onready var glow_material: ShaderMaterial = $SolidBody/GlowPolygon2D.material

var powerup_spawner: PowerupSpawner
var xp_orb_spawner: MultiplayerSpawner
var _sync_timer: float = 0.0
var _initial_drift_velocity: Vector2 = Vector2.ZERO
var _object_color: Color
var _glow_color: Color
var _color_rng := RandomNumberGenerator.new()

func _ready() -> void:
    area_entered.connect(_on_area_entered)
    glow_polygon.position = polygon.position
    glow_polygon.polygon = polygon.polygon
    _create_instance_materials()
    apply_color_seed(get_meta("color_seed", 0))

func _create_instance_materials() -> void:
    if glow_polygon.material:
        glow_material = (glow_polygon.material as ShaderMaterial).duplicate()
        glow_polygon.material = glow_material

func _initialize_physics(player_velocity: Vector2 = Vector2.ZERO) -> void:
    if not is_instance_valid(solid_body):
        return

    var angle := randf() * TAU

    var drift := Vector2.RIGHT.rotated(angle) * randf_range(
        maxf(0.0, base_drift_speed - drift_randomness),
        base_drift_speed + drift_randomness
    )

    var inherited_velocity := player_velocity * inherited_velocity_multiplier
    solid_body.linear_velocity = (inherited_velocity + drift).limit_length(max_drift_speed)
    _initial_drift_velocity = solid_body.linear_velocity

    solid_body.angular_velocity = randf_range(
        -rotation_speed,
        rotation_speed
    )

func apply_color_seed(seed: int) -> void:
    _color_rng.seed = seed
    var t: float = lerp(0.52, 0.83, _color_rng.randf())
    var hue: float = t
    var sat: float = lerp(0.6, 0.9, _color_rng.randf())
    var val: float = lerp(0.8, 1.0, _color_rng.randf())
    _object_color = Color.from_hsv(hue, sat, val, 1.0)

    var glow_hue := hue + _color_rng.randf_range(-0.05, 0.05)
    _glow_color = Color.from_hsv(glow_hue, sat * 0.8, 1.0, 1.0)
    _apply_colors()

func _apply_colors() -> void:
    polygon.modulate = _object_color
    if is_instance_valid(glow_material):
        glow_material.set_shader_parameter("glow_color", _glow_color)
    glow_polygon.modulate = Color.WHITE

func _physics_process(delta: float) -> void:
    _sync_area2d()

    if not multiplayer.is_server():
        return
    
    _sync_network(delta)

func _sync_area2d() -> void:
    global_position = solid_body.global_position
    global_rotation = solid_body.global_rotation

func _sync_network(delta: float) -> void:
    _sync_timer += delta
    if _sync_timer >= sync_interval:
        _sync_timer = 0.0
        sync_object_transform.rpc(
            solid_body.global_position,
            solid_body.global_rotation,
            solid_body.linear_velocity,
            solid_body.angular_velocity
        )
        
@rpc("authority", "call_local", "unreliable")
func sync_object_transform(
    pos: Vector2,
    rot: float,
    lin_vel: Vector2,
    ang_vel: float
) -> void:
    if multiplayer.is_server():
        return

    solid_body.global_position = pos
    solid_body.global_rotation = rot
    solid_body.linear_velocity = lin_vel
    solid_body.angular_velocity = ang_vel

func drop_powerup() -> void:
    if randf() > powerup_chance:
        return
    if powerup_pool.is_empty() or powerup_spawner == null:
        return
    var powerup_scene = powerup_pool.pick_random()
    powerup_spawner.spawn_powerup(
        powerup_scene,
        solid_body.global_position
    )
    
func drop_xp() -> void:
    if randf() > xp_chance:
        return
    var xp_amount = randf_range(xp_min, xp_max)
    if xp_orb_spawner:
        xp_orb_spawner.spawn_xp_orb(xp_amount, solid_body.global_position)

func clear_object(area: Node2D):
    spawn_break_particles(area)
    drop_xp()
    drop_powerup()
    
    if multiplayer.is_server():
        destroy_object.rpc()
    else:
        _destroy_locally()

@rpc("authority", "call_local", "reliable")
func destroy_object() -> void:
    _destroy_locally()

func _destroy_locally() -> void:
    if is_instance_valid(solid_body):
        var collision_shape = solid_body.get_node_or_null("SolidCollisionShape2D")
        if is_instance_valid(collision_shape):
            collision_shape.queue_free()
        solid_body.queue_free()
    
    var area_collision = get_node_or_null("CollisionShape2D")
    if is_instance_valid(area_collision):
        area_collision.queue_free()
    
    queue_free()
    
func spawn_break_particles(projectile: Projectile) -> void:
    var particles = break_particles_scene.instantiate() as GPUParticles2D

    get_tree().current_scene.add_child(particles)
    particles.global_position = solid_body.global_position
    particles.modulate = _object_color

    var opposite_direction = projectile.direction.normalized()
    particles.rotation = opposite_direction.angle()
    particles.one_shot = true
    particles.emitting = true

    get_tree().create_timer(particles.lifetime + 0.1).timeout.connect(particles.queue_free)

func _on_area_entered(area: Node2D) -> void:
    if not multiplayer.is_server():
        return
        
    if not is_instance_valid(area) or not is_instance_of(area, Projectile):
        return
        
    area = area as Projectile
    if area.shooter_is_enemy:
        return
    
    clear_object(area)
    area.clear_projectile()
