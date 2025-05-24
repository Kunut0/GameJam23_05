extends CharacterBody2D

func _process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player1"):
		body.speed /= 2
		body.jump_force *= 3/4

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player1"):
		body.speed *= 2
		body.jump_force /= 3/4

func _on_lifetime_timeout() -> void:
	queue_free()
