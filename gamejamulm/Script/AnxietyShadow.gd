extends CharacterBody2D

#var anger : ShadowBase = ShadowBase.new()
@onready var sprite = $AnimatedSprite2D
@onready var dash_timer = $DashTimer
@onready var hurt = $Hurtbox
@onready var scream_sprite: Sprite2D = $Area2D/Sprite2D

signal scream

var jump_force = -2000
var direction
var speed = 750

var dash_speed = 1800
var dashing = false
var dash_allowed = true

var stunned = false
var stun_time

var scream_allowed = true

var coyote = 0

func _ready() -> void:
	stun_time = 2

func _process(delta: float) -> void:
	
	#generates gravity for player
	if not is_on_floor():
		coyote += delta
		if velocity.y > 0:
			velocity += get_gravity() * delta * 8
		else:
			velocity += get_gravity() * delta * 8.75
	
	if is_on_floor():
		coyote = 0
	
	if stunned == false:
		#gets direction imput
		direction =  Input.get_axis("ui_left", "ui_right")
		
		#generates character movement
		if direction:
			if dashing:
				velocity.x = dash_speed * direction
			else:
				velocity.x = speed * direction
		else:
			if dashing:
				velocity.x = dash_speed * -1
			else:
				velocity.x = move_toward(velocity.x, 0, speed)
		
		#makes player jump when on floor
		if Input.is_action_just_pressed("ui_up") and coyote < 0.1:
			velocity.y = jump_force
			$Jump.play(1)
		
		if Input.is_action_just_pressed("ui_down"):
			if is_on_floor() and dash_allowed:
				$Dash.play()
				dashing = true
				dash_allowed = false
				dash_timer.start()
			elif not is_on_floor():
				velocity += get_gravity() * delta * 300
		
		if Input.is_action_just_pressed("ui_ctrl") and scream_allowed:
			scream_allowed = false
			sprite.scale += Vector2(0.05, 0.05)
			scream_sprite.self_modulate.a = 0.5
			scream_sprite.show()
			$Ability.play()
			await get_tree().create_timer(0.7).timeout
			scream_sprite.self_modulate.a = 1
			scream.emit()
			sprite.scale = Vector2(0.138, 0.138)
			sprite.play("scream")
			await get_tree().create_timer(0.125).timeout
			scream_sprite.hide()
			sprite.play("default")
			await get_tree().create_timer(1).timeout
			scream_allowed = true
	else:
		velocity.x = 0
	move_and_slide()

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	spawn()

func _on_hurtbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("player1"):
		body.respawn()

func stun():
	stunned = true
	hurt.monitoring = false
	$Stun.visible = true
	$AnimatedSprite2D.modulate = Color("6d6d6d")
	await get_tree().create_timer(stun_time).timeout
	stunned = false
	hurt.monitoring = true
	$AnimatedSprite2D.modulate = Color("ffffff")
	$Stun.visible = false

func spawn():
	var respawn_point_array = get_tree().get_nodes_in_group("respawn_point")
	var player_ref = get_tree().get_first_node_in_group("player1")
	var shadow_res = Vector2(0,0)
	for i in respawn_point_array: #respawn punkt für shadow wird gewählt
		if i.global_position.x - player_ref.global_position.x > 500:
			if shadow_res.x > i.global_position.x or shadow_res.x == 0:
				shadow_res = i.global_position
	global_position = shadow_res


func _on_dash_timer_timeout() -> void:
	dashing = false
	await get_tree().create_timer(0.1).timeout
	dash_allowed = true


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player1"):
		scream.connect(body.stun)

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("player1"):
		scream.disconnect(body.stun)
