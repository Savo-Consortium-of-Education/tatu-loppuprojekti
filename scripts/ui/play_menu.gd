extends Control

signal return_requested

@export var character_registry: CharacterRegistry

@onready var character_container: FlowContainer = %CharacterContainer
@onready var play_button: Button = %PlayButton
@onready var connect_text: TextEdit = %ConnectTextEdit
@onready var host_button: Button = %HostButton
@onready var join_button: Button = %JoinButton
@onready var leave_button: Button = %LeaveButton
@onready var player_list: ItemList = %PlayerListList
@onready var hp_label: Label = %HPLabel
@onready var speed_label: Label = %SpeedLabel
@onready var armor_label: Label = %ArmorLabel
@onready var rotation_label: Label = %RotationLabel
@onready var ability_label: Label = %AbilityLabel
@onready var ability_desc_label: Label = %AbilityDescLabel
@onready var damage_label: Label = %DamageLabel
@onready var dps_label: Label = %DPSLabel
@onready var projectile_label: Label = %ProjectileLabel
@onready var fire_rate_label: Label = %FireRateLabel
@onready var ability_energy_label: Label = %AbilityEnergyLabel
@onready var ability_drain_label: Label = %AbilityDrainLabel

const SELECT_CHARACTER: PackedScene = preload("res://scenes/menus/select_character.tscn")
const JOIN_LOBBY_SCENE: PackedScene = preload("res://scenes/menus/join_menu.tscn")

var prev_selected: Control

func _ready() -> void:
    load_characters()
    GameManager.character_selected.connect(_on_character_selected)
    Lobby.player_connected.connect(_on_player_connected)
    
    # select first character by default
    if character_container.get_child_count() > 0:
        var first_char = character_container.get_child(0)
        if first_char:
            first_char.select_button.button_pressed = true
            prev_selected = first_char
            GameManager.selected_character = first_char.character_data
            Lobby.set_player_character(first_char.character_data.resource_path)
            _on_character_selected(first_char.character_data, first_char)

func load_characters() -> void:
    if character_registry == null:
        print("character registry is missing!")
        return
    
    for data in character_registry.characters:
        if data == null:
            print("no character data")
            continue
            
        print("loading: ", data.character_name)
        var character_button = SELECT_CHARACTER.instantiate()
        character_button.character_data = data
        character_container.add_child(character_button)

func _on_play_button_pressed() -> void:
    if GameManager.selected_character:
        if multiplayer.has_multiplayer_peer() and multiplayer.is_server():
            Lobby.load_game.rpc("res://scenes/world.tscn")
        else:
            get_tree().change_scene_to_file("res://scenes/world.tscn")

func _on_character_selected(character_data: CharacterData, selected_node: Control) -> void:
    if character_data == null:
        return
    
    # unselect previous button
    if prev_selected != null and prev_selected != selected_node:
        prev_selected.select_button.button_pressed = false
    
    prev_selected = selected_node
        
    hp_label.text = "HP: %d" % character_data.max_hp
    armor_label.text = "Armor: %d" % character_data.armor
    speed_label.text = "Speed: %d" % character_data.max_speed
    rotation_label.text = "Rotation: %.1f" % character_data.rotation_speed
    
    var weapon = character_data.default_weapon
    if weapon:
        var damage = weapon.damage
        var fire_rate = weapon.fire_rate
        var projectile_count = weapon.projectile_count
        var dps = damage * fire_rate * projectile_count
        
        damage_label.text = "Damage/Shot: %d" % damage
        dps_label.text = "DPS: %.1f" % dps
        projectile_label.text = "Projectiles: %d" % projectile_count
        fire_rate_label.text = "Fire Rate: %.1f/s" % fire_rate
        ability_energy_label.text = "Ability Energy: %.1f" % character_data.max_ability
        ability_drain_label.text = "Ability Drain: %.1f/s" % character_data.ability_drain
    else:
        damage_label.text = "Damage/Shot: --"
        dps_label.text = "DPS: --"
        projectile_label.text = "Projectiles: --"
        fire_rate_label.text = "Fire Rate: --"
        ability_energy_label.text = "Ability Energy: --"
        ability_drain_label.text = "Ability Drain: --"
    
    # abilities from character data
    var ability_names = character_data.ability_names
    var ability_descs = character_data.ability_descriptions
    
    if ability_names.size() > 0:
        ability_label.text = "Ability: %s" % ", ".join(ability_names)
        ability_desc_label.text = "\n".join(ability_descs)
    else:
        ability_label.text = "Ability: None"
        ability_desc_label.text = "No abilities"

func _on_return_button_pressed() -> void:
    Lobby.leave_lobby()
    return_requested.emit()
    if get_parent() == get_tree().root:
        get_tree().change_scene_to_file("res://scenes/menus/main_menu.tscn")
    else:
        queue_free()

func _on_join_button_pressed() -> void:
    var join_menu = JOIN_LOBBY_SCENE.instantiate()
    add_child(join_menu)

func _on_host_button_pressed() -> void:
    var error = Lobby.create_game()
    if error != OK:
        print("Failed to create lobby: ", error)
        return
    connect_text.text = "%s:%s" % [Lobby.get_local_ip(), Lobby.current_port]

func set_lobby_view() -> void:
    host_button.disabled = true
    join_button.disabled = true
    leave_button.disabled = false
    connect_text.text = ""

func set_normal_view() -> void:
    host_button.disabled = false
    join_button.disabled = false
    leave_button.disabled = true
    connect_text.text = ""

func update_player_list() -> void:
    print(Lobby.player_info)
    player_list.clear()
    for player in Lobby.player_info:
        player_list.add_item(player, null, true)

func _on_player_connected(peer_id, player_info):
    print(peer_id, player_info)
    set_lobby_view()
    update_player_list()

func _on_leave_button_pressed() -> void:
    Lobby.leave_lobby()
    set_normal_view()
