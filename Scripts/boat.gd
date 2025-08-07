extends Area2D

signal player_entered_zone(player)
signal player_exited_zone(player)

@onready var interaction_zone: Area2D = $InteractionBox
var players_inside := []
@onready var vehicle = get_parent().get_node("Player")
var steering_speed := 120  # degrees per second
var boarded := false

@export var max_speed: float = 200.0				# max forward speed (pixels/sec)
@export var acceleration: float = 500.0				# acceleration rate (pixels/sec²)
@export var turn_speed: float = 1					# radians per second for turning
@export var linear_damping: float = 0.0005			# VERY LOW damping, slow bleed off when throttle released
@export var angular_damping: float = 5.0			# rotation damping

var speed: float = 0.0					# forward scalar speed
var angular_velocity: float = 0.0		# rotational speed (radians/sec)



func _ready():
	interaction_zone.body_entered.connect(_on_body_entered)
	interaction_zone.body_exited.connect(_on_body_exited)
	vehicle.connect("boarded", player_boarded)
	vehicle.connect("deboarded", player_deboarded)


func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		players_inside.append(body)
		emit_signal("player_entered_zone", body)


func _on_body_exited(body: Node) -> void:
	if body.is_in_group("player"):
		players_inside.erase(body)
		emit_signal("player_exited_zone", body)


func _process(delta: float) -> void:
	if not boarded:
		return
	# simple forward/back + rotation
	var forward = Input.get_axis("reverse", "drive_forward")
	var turn = Input.get_axis("turn_left", "turn_right")

	_handle_sailing(delta)
	_apply_movement(delta)
	
	#rotation += deg_to_rad(turn * steering_speed * delta)
	#position += Vector2(1, 0).rotated(rotation) * forward * speed * delta

func player_boarded() -> void:
	boarded = true
	
func player_deboarded() -> void:
	boarded = false
	
func _handle_sailing(delta: float) -> void:
	var forward_input = Input.get_axis("reverse", "drive_forward")
	var turn_input = Input.get_axis("turn_left", "turn_right")

	# --- Rotation ---
	var target_angular = turn_input * turn_speed
	var ang_diff = target_angular - angular_velocity
	var ang_accel = clamp(ang_diff, -angular_damping * delta, angular_damping * delta)
	angular_velocity += ang_accel
	if abs(turn_input) < 0.01:
		angular_velocity = lerp(angular_velocity, 0.0, clamp(angular_damping * delta, 0, 1))

	# --- Forward speed ---
	var target_speed = forward_input * max_speed
	if speed < target_speed:
		speed = min(speed + acceleration * delta, target_speed)
	elif speed > target_speed:
		speed = max(speed - acceleration * delta, target_speed)

	# Slow bleed off forward speed when no input, very gentle for drifting feel
	if abs(forward_input) < 0.01:
		if speed > 0:
			speed = max(speed - linear_damping * delta, 0)
		elif speed < 0:
			speed = min(speed + linear_damping * delta, 0)

func _apply_movement(delta: float) -> void:
	rotation += angular_velocity * delta
	var forward_dir = Vector2.UP.rotated(rotation).normalized()
	position += forward_dir * speed * delta
