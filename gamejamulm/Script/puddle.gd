extends CharacterBody2D

func _process(delta: float) -> void:
	if not is_on_floor():
		velocity.y = 10000
		$Sprite2D.visible = false
	else:
		$Sprite2D.visible = true
	move_and_slide()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player1"):
		body.speed /= 2.5
		body.jump_force *= 0.65

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player1"):
		body.speed *= 2.5
		body.jump_force /= 0.65

func _on_lifetime_timeout() -> void:
	queue_free()
