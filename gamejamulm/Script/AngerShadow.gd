extends CharacterBody2D

var anger : ShadowBase = load("res://Script/shadow_base.gd").new()
 
func _ready() -> void:
	anger.speed = 300
	
func _process(delta: float) -> void:
	pass

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	anger.spawn()
