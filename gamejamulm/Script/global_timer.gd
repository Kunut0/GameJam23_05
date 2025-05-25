extends Timer

func _on_timeout() -> void:
	get_tree().change_scene_to_file("res://Szene/Player2Win.tscn")
