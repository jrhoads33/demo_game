extends Area2D
class_name Projectile        # handy if you want to spawn by name
@export var speed        : float = 400.0
@export var damage       : int   = 1
@export var lifetime_sec : float = 1.5

var _velocity : Vector2 = Vector2.ZERO

func _ready() -> void:
	$Lifetime.wait_time = lifetime_sec
	$Lifetime.start()
	connect("area_entered", Callable(self, "_on_area_entered"))

func _physics_process(delta: float) -> void:
	position += _velocity * delta

func fire(dir: Vector2) -> void:
	# dir must be normalized
	_velocity = dir * speed
	rotation = dir.angle()   # purely visual

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemy"):
		area.take_damage(damage)   # your own API
		queue_free()

func _on_Lifetime_timeout() -> void:
	queue_free()
