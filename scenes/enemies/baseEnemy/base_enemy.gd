class_name Enemy extends CharacterBody2D

@export var max_hp: float = 100
@export var move_speed: float = 100
@export var damage: float = 5.0
@export var shoot_projectiles: bool = false
#@export var projectile = null

var hp: float

func _ready() -> void:
	hp = max_hp
	
func die():
	queue_free()
	
func take_damage(amount: float):
	hp -= amount
	if(hp <= 0):
		die()
		
func get_closest_player():
	var all_players = get_tree().get_nodes_in_group("players")
	var closest_player = null
	
	if all_players.size() > 0:
		closest_player = all_players[0]
		for player in all_players:
			var distance_to_this_player = global_position.distance_squared_to(player.global_position)
			var distance_to_closest_player = global_position.distance_squared_to(closest_player.global_position)
			if (distance_to_this_player < distance_to_closest_player):
				closest_player = player
				
	return closest_player
	
func _physics_process(delta: float) -> void:
	var closest_player = get_closest_player();
	move_towards_player(closest_player)
	
func move_towards_player(player: Player):
	var direction = global_position.direction_to(
		player.global_position
	)
	velocity = direction * move_speed
	move_and_slide()
