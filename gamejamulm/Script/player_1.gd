extends CharacterBody2D

@onready var sprite = $PlaceholderSprite
@onready var camera = $Camera2D

# noch nicht getestet
var jump_force = 400
var direction
var speed = 400

func _process(delta: float) -> void:
	
	#generates gravity for player
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	#gets direction imput
	direction =  Input.get_axis("ui_a", "ui_d")
	
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
	if Input.is_action_just_pressed("ui_w") and is_on_floor():
		velocity.y = jump_force
	
	if Input.is_action_just_pressed("ui_s"):
		pass
	
	move_and_slide()
	
	
	#Kamera Lerping not tested yet
	var shadow_ref = get_tree().get_first_node_in_group("shadow")
	var pos_diff = self.global_position - shadow_ref.global_position
	var camera_pos
	if  pos_diff < -200:
		camera_pos = 100
	elif pos_diff > 200:
		camera_pos = -100
	else:
		camera_pos = pos_diff * (-0.5)
	camera.position = lerp(camera.position, pos_diff, 0.1)
