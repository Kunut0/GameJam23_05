extends Label

func _process(delta: float) -> void:
	text = str(int(GlobalTimer.time_left))
	
	global_position = get_tree().get_first_node_in_group("cam").global_position + Vector2(-40,-500)
