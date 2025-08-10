extends CharacterBody2D
@export var projectile_scene : PackedScene = preload("res://Scenes/Projectile.tscn")
@export var grapple_scene : PackedScene = preload("res://Scenes/grapple.tscn")

@export var projectile_spawn_offset : float = 8.0   # moves bullet out of the player hurtbox
@export var fire_cooldown := 0.2                     # seconds between shots
var time_since_last_shot := 0.0  # initialize at the script level
@onready var health_label : Label = $Label
@onready var knockback_timer : Timer = $KnockbackTimer

@export var move_speed := 100.0
var last_facing_dir : Vector2 = Vector2.RIGHT   # (1, 0)
var on_board := false
var near_boat := false

var player_health := 100
var knockback_velocity 
var resistance = 5
var stunned := false

func _ready():
	add_to_group('player')
	
func _on_player_near_vehicle(player):
	near_boat = true

func _on_player_left_vehicle(player):
	near_boat = false


func _input(event):
	if event.is_action_pressed("grapple"):
		if get_tree().get_first_node_in_group("grapple") == null:
			_handle_grapple()
		

func _physics_process(delta):
	if stunned:
		return
	_handle_movement(delta)
	_handle_shooting(delta)

func _handle_grapple():
		var dir := _get_aim_vector()
		if dir != Vector2.ZERO:
			var grapple := grapple_scene.instantiate() as Grapple
			grapple.global_position = global_position + dir * projectile_spawn_offset
			grapple.fire(dir)                    # pass direction -> sets velocity
			get_parent().add_child(grapple)

func _handle_shooting(delta: float) -> void:
	time_since_last_shot += delta
	if Input.is_action_pressed("shoot") and time_since_last_shot >= fire_cooldown:
		var dir := _get_aim_vector()
		if dir != Vector2.ZERO:
			_spawn_projectile(dir)
			time_since_last_shot = 0.0

func _handle_movement(delta: float) -> void:
	# Get input vector from defined input actions, normalized automatically
	var input_vector: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")

	# Update facing direction only when moving
	if input_vector != Vector2.ZERO:
		last_facing_dir = input_vector.normalized()

	# Set velocity for CharacterBody2D
	velocity = input_vector * move_speed
	move_and_slide()
	
func _spawn_projectile(dir: Vector2) -> void:
	var bullet := projectile_scene.instantiate() as Projectile
	bullet.global_position = global_position + dir * projectile_spawn_offset
	bullet.fire(dir)                    # pass direction -> sets velocity
	get_parent().add_child(bullet)      # or a  dedicated “Projectiles” node

func _get_aim_vector() -> Vector2:
	var mouse_global = get_global_mouse_position()
	var direction = (mouse_global - global_position).normalized()
	return direction
 
func take_damage(damage : int):
	player_health -= damage
	update_hud()
	#if player_health <= 0:
		#queue_free()

func update_hud() -> void:
	health_label.text = "Health : " + str(player_health)

func apply_knockback(from: Vector2, strength: float):
	var dir = (position - from).normalized()
	position += dir * strength/resistance
	knockback_timer.start(0.5)
	stunned = true


func _on_knockback_timer_timeout() -> void:
	stunned = false
