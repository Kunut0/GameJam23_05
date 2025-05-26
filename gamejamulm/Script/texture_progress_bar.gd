extends TextureProgressBar

func _process(delta: float) -> void:
	if GameMode.GameMode == "arcade":
		max_value = 300
	else:
		max_value = 200
	value = GlobalTimer.time_left
