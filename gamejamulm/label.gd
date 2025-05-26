extends Label

func _process(delta: float) -> void:
	text = str(int(GlobalTimer.time_left))
