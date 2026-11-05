class_name CharacterData
extends Resource

@export_group("Identity")
@export var character_name: String = "Unnamed"
@export var portrait: Texture2D

@export_group("Health & Boost")
@export var max_hp: float = 100.0
@export var max_boost: float = 100.0
@export var boost_multiplier: float = 1.2
@export var boost_recovery: float = 20.0
@export var boost_drain: float = 35.0

@export_group("Movement")
@export var rotation_speed: float = 3.0
@export var linear_drag: float = 40.0
@export var angular_drag: float = 2.0
@export var max_speed: float = 300.0
@export var acceleration: float = 150.0

@export_group("Weapons")
@export var default_weapon: WeaponData
