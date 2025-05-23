extends CharacterBody2D

class_name ShadowBase

@onready var sprite

var jump_force = 400
var direction
var speed = 400

func _process(delta: float) -> void:
	
	#generates gravity for player
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	#gets direction imput
	direction =  Input.get_axis("ui_left", "ui_right")
	
	#checks direction to flip sprite
	if direction < 0:
		sprite.flip_h = true
	else:
		sprite.flip_h = false
	
	#generates character movement
	if direction:
		velocity.x = speed * direction
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
	
	#makes player jump when on floor
	if Input.is_action_just_pressed("ui_up") and is_on_floor():
		velocity.y = jump_force
	
	move_and_slide()
