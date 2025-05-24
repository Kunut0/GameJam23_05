extends CharacterBody2D

@onready var sprite = $PlaceholderSprite
@onready var camera = $Camera2D
@onready var dash_timer = $DashTimer
@onready var dash_collision = $DashCollision
@onready var default_collision = $NormalCollision

# noch nicht getestet
var jump_force = -400
var direction
var speed = 400

var dash_speed = 1500
var dashing = false
var dash_allowed = true

var shadow_ref
var respawn_ref

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
		if dashing:
			velocity.x = dash_speed * direction
		else:
			velocity.x = speed * direction
	else:
		if dashing:
			velocity.x = dash_speed * 1
		else:
			velocity.x = move_toward(velocity.x, 0, speed)
	
	#makes player jump when on floor
	if Input.is_action_just_pressed("ui_w") and is_on_floor():
		velocity.y = jump_force
	
	#slide
	if Input.is_action_just_pressed("ui_s") and is_on_floor() and dash_allowed:
		dashing = true
		dash_allowed = false
		dash_collision.disabled = false
		default_collision.disabled = true
		dash_timer.start()
	
	move_and_slide()
	
	
	#Kamera Lerping
	shadow_ref = get_tree().get_first_node_in_group("shadow")
	var pos_diff = self.global_position - shadow_ref.global_position
	var camera_pos: float
	if  pos_diff.x < -200:
		camera_pos = 100
	elif pos_diff.x > 200:
		camera_pos = -100
	else:
		camera_pos = pos_diff.x * (-0.5)
	camera.position.x = lerp(camera.position.x, camera_pos, 0.1)

#respawn
func respawn():
	self.global_position = respawn_ref.global_position
	shadow_ref.spawn()

#dash timer
func _on_timer_timeout() -> void:
	dashing = false
	default_collision.disabled = false
	dash_collision.disabled = true
	await get_tree().create_timer(0.1).timeout
	dash_allowed = true
