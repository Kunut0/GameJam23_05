extends CollisionShape2D

var pos

func _physics_process(delta: float) -> void:
	global_position = pos
