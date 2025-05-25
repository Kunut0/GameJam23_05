extends Marker2D

func _on_respawn_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player1"):
		body.respawn_ref = global_position
