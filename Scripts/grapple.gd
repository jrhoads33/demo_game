extends Area2D

class_name Grapple

@export var speed : float = 300.0
@export var range : float = 200.0 
@export var min_length : float = 10
var _velocity : Vector2 = Vector2.ZERO
@onready var rope : Line2D = $rope
var player : CharacterBody2D

# TODO - add state to track, enums? 
var is_returning : bool = false
var attached : bool = false

var attached_enemy : Area2D

var spear_pos : Vector2 


func _ready() -> void:
	player = get_parent().get_node("Player")
	add_to_group("grapple")
	

func _physics_process(delta: float) -> void:
	if is_returning:
		_velocity = -speed * (global_position - player.global_position).normalized()
	position += _velocity * delta
	spear_pos = global_position if not attached else attached_enemy.global_position
	update_rope(player.global_position, spear_pos)
	if attached:
		global_position = attached_enemy.global_position


func fire(dir: Vector2) -> void:
	# dir must be normalized
	_velocity = dir * speed
	rotation = dir.angle() + PI/2   # purely visual
	
func update_rope(player_pos: Vector2, hook_pos: Vector2):
	rotation = (global_position - player.global_position).angle() + PI/2
	rope.set_point_position(0, to_local(player_pos))
	rope.set_point_position(1, to_local(hook_pos))
	if not is_returning and (global_position - player.global_position).length() > range:
		is_returning = true
		print("returning")
	if is_returning and (global_position - player.global_position).length() < min_length:
		queue_free()
	
func get_len() -> float:
	return (global_position - player.global_position).length()


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemies"):
		attached = true
		attached_enemy = area
		area.connect("death", Callable(self, "on_enemy_death"))
		print("hit" + str(attached_enemy.name))
		
func on_enemy_death() -> void:
	attached = false
	is_returning = true
