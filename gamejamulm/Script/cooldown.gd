extends Node

var on_cooldown = {
	"flashlight": [false, 5],#
	"dashing": [false, 1]
}

func _process(delta: float) -> void:
	if on_cooldown["flashlight"][0] == true:
		print("ok")
	if on_cooldown["flashlight"][0]:
		await get_tree().create_timer(on_cooldown["flashlight"][1]).timeout
		on_cooldown["flashlight"][0] = false
	if on_cooldown["dashing"][0]:
		await get_tree().create_timer(on_cooldown["dashing"][1]).timeout
		on_cooldown["dashing"][0] = false
