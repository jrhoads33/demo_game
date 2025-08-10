extends TileMapLayer

@onready var doors = $DoorLayer
func _ready() -> void:
	add_to_group("walls")
	doors.add_to_group("walls")
