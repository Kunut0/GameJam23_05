extends CharacterBody2D

@onready var sprite = $AnimatedSprite2D
@onready var camera = $Camera2D
@onready var dash_timer = $DashTimer
@onready var dash_collision = $DashCollision
@onready var default_collision = $NormalCollision
@onready var lichtkegel: Area2D = $Lichtkegel

signal flashlight

# noch nicht getestet
var jump_force = -400
var direction
var speed = 400

var dash_speed = 1500
var dashing = false
var dash_allowed = true

var shadow_ref
var respawn_ref

var light_timer
var lichtkegel_sichtbar: bool = false
var enemy_sight: bool = false

func _ready() -> void:
	shadow_ref = get_tree().get_first_node_in_group("shadow")
	
	lichtkegel.hide()
	lichtkegel.monitoring = false

func _process(delta: float) -> void:
	
	#generates gravity for player
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	#gets direction imput
	direction = Input.get_axis("ui_a", "ui_d")
	
	#checks direction to flip sprite
	if direction < 0:
		self.scale.y = -1
		self.rotation_degrees = 180
		sprite.play("walk")
	elif direction > 0:
		self.scale.y = 1
		self.rotation_degrees = 0
		sprite.play("walk")
	elif direction == 0:
		sprite.play("default")
	
	#generates character movement
	if direction:
		if dashing:
			velocity.x = dash_speed * direction
		else:
			velocity.x = speed * direction
	else:
		if dashing:
			velocity.x = dash_speed * direction
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
	
	if Input.is_action_just_pressed("ui_select"):
		if lichtkegel_sichtbar == false:
			lichtkegel.show()
			lichtkegel.monitoring = true
			lichtkegel_sichtbar = true
			
	
	
	elif Input.is_action_just_released("ui_select"):
		if lichtkegel_sichtbar == true:
			lichtkegel.hide()
			lichtkegel.monitoring = false
			lichtkegel_sichtbar = false
			await get_tree().create_timer(0.5).timeout
			flashlight.emit()
	
	if lichtkegel_sichtbar and enemy_sight:
		light_timer += 1*delta
		if light_timer > 1:
			flashlight.emit()
	else:
		light_timer = 0
	
	#Kamera Lerping
	var pos_diff = global_position - shadow_ref.global_position
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
	global_position = respawn_ref.global_position
	shadow_ref.spawn()

#dash timer
func _on_timer_timeout() -> void:
	dashing = false
	default_collision.disabled = false
	dash_collision.disabled = true
	await get_tree().create_timer(0.1).timeout
	dash_allowed = true


func _on_lichtkegel_body_entered(body: Node2D) -> void:
	if body.is_in_group("shadow"):
		enemy_sight = true
		flashlight.connect(body.stun)


func _on_lichtkegel_body_exited(body: Node2D) -> void:
	if body.is_in_group("shadow"):
		enemy_sight = false
		flashlight.disconnect(body.stun)
