extends Area2D

@export var SPEED = 50.0
const JUMP_VELOCITY = -400.0
@onready var player : Area2D = get_parent().get_node("Player")

var enemy_health : int = 100
var velocity : Vector2

func _ready() -> void:
	add_to_group("enemies")

func _physics_process(delta: float) -> void:
	
	_handle_movement(delta)

func _handle_movement(delta) -> void:
	var dir_vect = player.position - position
	velocity = dir_vect.normalized() * SPEED
	position += velocity * delta

func take_damage(damage: int) -> void:
	""" takes damage and checks if the enemy is alive """
	enemy_health -= damage
	print(enemy_health)
	if enemy_health <= 0:
		queue_free()

func _on_hit_box_2_area_entered(area: Area2D) -> void:
	if area.is_in_group('player'):
		area.take_damage(20)
		area.apply_knockback(global_position, 250)
