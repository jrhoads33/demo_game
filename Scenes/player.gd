extends CharacterBody2D
@export var projectile_scene : PackedScene = preload("res://Scenes/Projectile.tscn")
@export var projectile_spawn_offset : float = 8.0   # moves bullet out of the player hurtbox
@export var fire_cooldown := 0.2                     # seconds between shots
var time_since_last_shot := 0.0  # initialize at the script level

@export var move_speed := 100.0
var last_facing_dir : Vector2 = Vector2.RIGHT   # (1, 0)
var on_board := false
var near_boat := false
@onready var vehicle = get_parent().get_node("boat")
signal boarded
signal deboarded

func _ready():
	add_to_group('player')
	
	vehicle.player_entered_zone.connect(_on_player_near_vehicle)
	vehicle.player_exited_zone.connect(_on_player_left_vehicle)
	
func _on_player_near_vehicle(player):
	near_boat = true

func _on_player_left_vehicle(player):
	near_boat = false


func _input(event):
	if event.is_action_pressed("interact"):
		if near_boat and not on_board:
			board_boat()
		elif near_boat and on_board:
			deboard()
		

func _physics_process(delta):
	if not on_board:
		_handle_movement(delta)
	else:
		position = vehicle.position
	_handle_shooting(delta)
		

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

	# Move the player
	move_and_slide()

	
func _spawn_projectile(dir: Vector2) -> void:
	var bullet := projectile_scene.instantiate() as Projectile
	bullet.global_position = global_position + dir * projectile_spawn_offset
	bullet.fire(dir)                    # pass direction -> sets velocity
	get_parent().add_child(bullet)      # or a  dedicated “Projectiles” node

func _get_aim_vector() -> Vector2:
	return last_facing_dir.normalized()
	
func board_boat() -> void:
	on_board = true
	emit_signal("boarded")
	
func deboard() -> void:
	on_board = false
	emit_signal("deboarded")
	
