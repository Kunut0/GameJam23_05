extends Area2D


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player1") and body.dashing:
		body.dash_timer.set_paused(true)

func _on_body_left(body: Node2D) -> void:
	if body.is_in_group("player1") and body.dashing:
		body.dash_timer.set_paused(false)
