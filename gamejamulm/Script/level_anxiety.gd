extends Node2D

func _ready() -> void:
	if GameMode.GameMode == "default":
		GlobalTimer.start()
		MainMenuMusik.stop()
