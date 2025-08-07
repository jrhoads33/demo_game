extends Node2D
@export var spawn_radius_min: float = 200.0
@export var spawn_radius_max: float = 400.0
@export var enemy_scene: PackedScene = preload("res://Scenes/enemy.tscn")

@onready var player = $"Player" 
@onready var spawn_timer: Timer = $SpawnTimer

func _ready():
	spawn_timer.timeout.connect(spawn_enemy)
	spawn_timer.start()

func spawn_enemy():
	var angle = randf_range(0, TAU)  # 0 to 2π
	var distance = randf_range(spawn_radius_min, spawn_radius_max)
	var offset = Vector2.RIGHT.rotated(angle) * distance
	var spawn_position = player.global_position + offset

	var enemy = enemy_scene.instantiate()
	enemy.global_position = spawn_position
	get_tree().current_scene.add_child(enemy)
