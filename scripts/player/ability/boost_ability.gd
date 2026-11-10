class_name BoostAbility
extends PlayerAbility

func process_ability(delta: float) -> void:
    var requested := Input.is_action_pressed("ability") and player.boost_energy > 0.0
    set_active(requested)

    if active:
        player.boost_energy = maxf(
            player.boost_energy - player.boost_drain * delta,
            0.0
        )
    else:
        player.boost_energy = minf(
            player.boost_energy + player.boost_recovery * delta,
            player.max_boost
        )

    GameManager.boost_player(player, player.boost_energy)

func movement_multiplier() -> float:
    return player.boost_multiplier if active else 1.0
