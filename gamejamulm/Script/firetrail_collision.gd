extends CollisionShape2D

var pos

func _ready() -> void:
	pos = global_position

func _physics_process(delta: float) -> void:
	global_position = pos
