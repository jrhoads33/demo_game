extends Area2D

@export var SPEED = 50.0
const JUMP_VELOCITY = -400.0
@onready var player : CharacterBody2D = get_parent().get_node("Player")

var enemy_health : int = 100
var velocity : Vector2
var player_class : String
@onready var class_label : Label = $ClassLabel

signal death


func initialize(player_class_name : String) -> void:
	player_class = player_class_name
	

func _ready() -> void:
	add_to_group("enemies")
	class_label.text = player_class
	class_label.visible = true

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
		emit_signal("death")
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		if body.has_method("take_damage"):
			body.take_damage(20)
		if body.has_method("apply_knockback"):
			body.apply_knockback(global_position, 250)
