extends Marker2D

@onready var base = $AnimatedSprite2D
@onready var smoke = $AnimatedSprite2D2

var shadow

func spawn_shadow():
	base.play(shadow)
	
	smoke.show()
	smoke.play("default")


func _on_animated_sprite_2d_2_animation_finished() -> void:
	smoke.hide()
	
	base.play("hide")
