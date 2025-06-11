extends CharacterBody2D

@onready var sprite = $AnimatedSprite2D
@onready var dash_timer = $DashTimer
@onready var dash_collision = $DashCollision
@onready var default_collision = $NormalCollision
@onready var lichtkegel: Area2D = $Lichtkegel

signal flashlight

# noch nicht getestet
var jump_force = -1700
var direction
var speed = 700

var dash_speed = 1300
var dashing = false
var dash_allowed = true

var shadow_ref
var respawn_ref

var jumping = false

var light_timer = 0
var lichtkegel_sichtbar: bool = false

var enemy_sight: bool = false

var stunned = false
var stun_time = 1.5

var coyote = 0

func _ready() -> void:
	shadow_ref = get_tree().get_first_node_in_group("shadow")
	respawn_ref = get_tree().get_first_node_in_group("first").global_position
	
	lichtkegel.hide()
	lichtkegel.monitoring = false

func _process(delta: float) -> void:
	
	#generates gravity for player
	if not is_on_floor():
		coyote += delta
		if velocity.y > 0:
			velocity += get_gravity() * delta * 6
		else:
			velocity += get_gravity() * delta * 6.75
	
	if is_on_floor() or $RayCast2D3.is_colliding() or $RayCast2D2.is_colliding() or $RayCast2D.is_colliding():
		coyote = 0
	
	if stunned == false:
		#gets direction imput
		direction = Input.get_axis("ui_a", "ui_d")
		
		#checks direction to flip sprite
		if direction < 0:
			self.scale.y = -2.25
			self.rotation_degrees = 180
		elif direction > 0:
			self.scale.y = 2.25
			self.rotation_degrees = 0
		
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
		if Input.is_action_just_pressed("ui_select") and coyote < 0.2:
			velocity.y = jump_force
			sprite.play("jump")
			$Jump.play()
		
		#slide
		if Input.is_action_just_pressed("ui_s"):
			if not is_on_floor():
				velocity += get_gravity() * delta * 400
	else:
		velocity.x = 0
	
	move_and_slide()
	
	
	if lichtkegel_sichtbar and enemy_sight:
		light_timer += 1*delta
		if light_timer > 0.25:
			$Stun.play()
			lichtkegel.modulate = Color("ffff00")
			flashlight.emit()
			lichtkegel.monitoring = false
			await get_tree().create_timer(0.2).timeout
			lichtkegel.modulate = Color("ffffff")
			lichtkegel.hide()
			Cooldown.on_cooldown["flashlight"][0] = true
	elif light_timer > 0:
		light_timer -= 0.5*delta
	else:
		light_timer = 0
	
	
	
	#animations
	if is_on_floor():
		jumping = false
		if dashing:
			sprite.play("dash")
		elif direction == 0:
			sprite.play("default")
		elif direction != 0:
			sprite.play("walk")
	elif velocity.y < 0 and jumping == false:
		sprite.play("jump")
		jumping = true

func _input(event: InputEvent) -> void:
	if Input.is_action_pressed("ui_flashlight") and Cooldown.on_cooldown["flashlight"][0] == false and stunned == false:
		if lichtkegel_sichtbar == false:
			$Flashlight.play()
			lichtkegel.show()
			lichtkegel.monitoring = true
			lichtkegel_sichtbar = true
	
	elif Input.is_action_just_released("ui_flashlight"):
		if lichtkegel_sichtbar == true:
			lichtkegel.hide()
			lichtkegel.monitoring = false
			lichtkegel_sichtbar = false
			flashlight.emit()
	
	if Input.is_action_just_pressed("ui_s"):
		if coyote < 0.2 and dash_allowed == true:
			dash_allowed = false
			$Slide.play()
			dashing = true
			dash_collision.disabled = false
			default_collision.disabled = true
			sprite.offset = Vector2(90, 160)
			dash_timer.start()
			await get_tree().create_timer(0.1).timeout
			sprite.offset = Vector2(0, 0)

#respawn
func respawn():
	for i in get_tree().get_nodes_in_group("shadow_prop"):
		i.queue_free()
	global_position = respawn_ref
	shadow_ref.spawn()
	
	Cooldown.on_cooldown["flashlight"][0] = false
	stun_stop()

#dash timer
func _on_timer_timeout() -> void:
	dashing = false
	default_collision.disabled = false
	dash_collision.disabled = true
	await get_tree().create_timer(0.5).timeout
	dash_allowed = true


func _on_lichtkegel_body_entered(body: Node2D) -> void:
	if body.is_in_group("shadow"):
		enemy_sight = true
		flashlight.connect(body.stun)


func _on_lichtkegel_body_exited(body: Node2D) -> void:
	if body.is_in_group("shadow"):
		enemy_sight = false
		flashlight.disconnect(body.stun)


func stun():
	stunned = true
	$Stun2.visible = true
	await get_tree().create_timer(stun_time).timeout
	stun_stop()

func stun_stop():
	stunned = false
	$Stun2.visible = false
	lichtkegel.hide()
	lichtkegel.monitoring = false
	lichtkegel_sichtbar = false
