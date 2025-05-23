extends CharacterBody2D

var anger : ShadowBase = ShadowBase.new()
 
func _ready() -> void:
	anger.speed = 300

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_up"):
		pass
