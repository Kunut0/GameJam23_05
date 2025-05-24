extends Node

var on_cooldown = {
	"flashlight": [false, 5],
}

func _process(delta: float) -> void:
	if on_cooldown["flashlight"][0] == true:
		print("ok")
