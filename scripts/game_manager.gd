extends Node

signal player_damaged(player: Player, damage: int)
signal player_healed(player: Player, heal: int)
signal player_levelup(player: Player)
signal score_changed(new_score: int)
signal game_ended()

var selected_character: CharacterData
var score: int = 0

func damage_player(player: Player, damage: int):
	player.current_hp -= damage
	player_damaged.emit(player, damage)

func heal_player(player: Player, heal: int):
	player.current_hp += heal
	player_healed.emit(player, heal)

func levelup_player(player: Player):
	player.current_level += 1
	player_levelup.emit(player)

func add_score(points) -> void:
	score += points
	score_changed.emit(score)

func end_game() -> void:
	game_ended.emit()

func reset() -> void:
	score = 0
