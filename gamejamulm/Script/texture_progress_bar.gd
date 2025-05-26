extends TextureProgressBar

func _process(delta: float) -> void:
	value = GlobalTimer.time_left
