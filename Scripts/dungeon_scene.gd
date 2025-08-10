extends Node2D
@export var spawn_radius_min: float = 200.0
@export var spawn_radius_max: float = 400.0
@export var enemy_scene: PackedScene = preload("res://Scenes/enemy.tscn")

@onready var player = $"Player" 
@onready var spawn_timer: Timer = $SpawnTimer

var enemy_type : Array = ['melee', "ranged", "magic"]

func _ready():
	spawn_enemy(3)
	spawn_timer.timeout.connect(spawn_enemy)
	spawn_timer.start()

func spawn_enemy(num_enemies : int = 2):
	for i in range(num_enemies):
		var angle = randf_range(0, TAU)  # 0 to 2π
		var distance = randf_range(spawn_radius_min, spawn_radius_max)
		var offset = Vector2.RIGHT.rotated(angle) * distance
		var spawn_position = player.global_position + offset

		var enemy = enemy_scene.instantiate()
		enemy.global_position = spawn_position
		enemy.initialize(enemy_type[randi_range(0,2)])
		get_tree().current_scene.add_child(enemy)
