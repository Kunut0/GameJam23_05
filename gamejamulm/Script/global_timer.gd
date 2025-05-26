extends Timer

func _on_timeout() -> void:
	if GameMode.GameMode == "default":
		get_tree().change_scene_to_file("res://Szene/Player2Win.tscn")
	elif GameMode.GameMode == "arcade":
		get_tree().change_scene_to_file("res://Szene/arcadeEnd.tscn")
