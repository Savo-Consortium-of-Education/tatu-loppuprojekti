class_name Weapon
extends Node

var weapon_data: WeaponData
var owner_character: Character

var cooldown: float = 0.0

func _process(delta: float) -> void:
    cooldown = maxf(cooldown - delta, 0.0)

func try_fire(direction: Vector2) -> void:
    if cooldown > 0.0:
        return
    if weapon_data == null:
        return

    shoot(direction.normalized())
    cooldown = 1.0 / weapon_data.fire_rate

func shoot(direction: Vector2) -> void:
    if weapon_data.projectile_scene == null:
        push_error("weapon_data.projectile_scene == null")
        return

    if weapon_data.fire_rate <= 0.0:
        push_error("weapon_data.fire_rate <= 0.0")
        return
        
    for i in weapon_data.projectile_count:
        var projectile = weapon_data.projectile_scene.instantiate() as Projectile
        if projectile == null:
            continue

        var spread_angle = deg_to_rad(
            randf_range(-weapon_data.spread, weapon_data.spread))

        var shot_direction = direction.rotated(spread_angle)
        owner_character.get_tree().current_scene.add_child(projectile)

        projectile.global_position = owner_character.global_position
        projectile.direction = shot_direction
        projectile.speed = weapon_data.projectile_speed
        projectile.damage = weapon_data.damage
        projectile.shooter = owner_character
