extends CharacterBody2D

#var anger : ShadowBase = ShadowBase.new()
@onready var sprite = $AnimatedSprite2D
@onready var dash_timer = $DashTimer
@onready var jump_timer = $JumpHeightTimer
@onready var buffering_timer = $BufferingTimer
@onready var hurt = $Hurtbox
@onready var scream_sprite: Sprite2D = $Area2D/Sprite2D
@onready var nav = $NavigationAgent2D

var shadow_scene = preload("res://Szene/AnxietyShadow.tscn")

signal scream

var jump_force = -2000
var direction
var speed = 850

var buffered_input: String

var dash_speed = 1500
var dashing = false
var dash_allowed = true
var dash_direction = -1

var stunned = false
var stun_time

var scream_allowed = true

var coyote = 0

var respawning = true

func _ready() -> void:
	stun_time = 2
	
	sprite.play("spawn")

func _process(delta: float) -> void:
	if !respawning:
		#generates gravity for player
		if not is_on_floor():
			coyote += delta
			if velocity.y > 0:
				velocity += get_gravity() * delta * 8
			else:
				velocity += get_gravity() * delta * 10
		
		if is_on_floor():
			coyote = 0
		
		if stunned == false:
			if GameMode.GameMode == "default":
				#gets direction imput
				direction =  Input.get_axis("ui_left", "ui_right")
				
				if Input.is_action_pressed("ui_down"):
					if not is_on_floor():
						velocity += get_gravity() * delta * 300
				
				if direction < 0:
					dash_direction = -1
				elif direction > 0:
					dash_direction = 1
			
			#generates character movement
			if direction:
				if dashing:
					velocity.x = dash_speed * direction
				else:
					velocity.x = speed * direction
			else:
				if dashing:
					velocity.x = dash_speed * dash_direction
				else:
					velocity.x = move_toward(velocity.x, 0, speed)
			
		else:
			velocity.x = 0
		move_and_slide()
	
	else:
		velocity.y = 0
	
func _input(event: InputEvent) -> void:
	if stunned ==  false and !respawning:
		#makes player jump when on floor
		if Input.is_action_just_pressed("ui_up"):
			if coyote < 0.1:
				velocity.y = jump_force
				$Jump.play(1)
				jump_timer.start()
			else:
				buffering_timer.start()
				buffered_input = "jump"
				
		
		if Input.is_action_just_pressed("ui_ctrl") and scream_allowed:
			screaming()
		
		if Input.is_action_just_pressed("ui_down"):
			if coyote < 0.1 and dash_allowed:
				dashing_action()
			else:
				buffering_timer.start()
				buffered_input = "dash"

func dashing_action():
	$Dash.play()
	dashing = true
	dash_allowed = false
	dash_timer.start()

func screaming():
	scream_allowed = false
	sprite.play("scream")
	scream_sprite.self_modulate.a = 0.5
	scream_sprite.show()
	$Ability.play()
	
	await get_tree().create_timer(0.7).timeout
	
	scream_sprite.self_modulate.a = 1
	sprite.scale += Vector2(0.05, 0.05)
	scream.emit()
	
	await get_tree().create_timer(0.2).timeout
	
	scream_sprite.hide()
	sprite.scale = Vector2(0.138, 0.138)
	sprite.play("default")
	
	await get_tree().create_timer(2).timeout
	
	scream_allowed = true

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	spawn()

func _on_hurtbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("player1"):
		print("hit")
		body.respawn()

func stun():
	stunned = true
	hurt.monitoring = false
	$Stun.visible = true
	$AnimatedSprite2D.modulate = Color("6d6d6d")
	await get_tree().create_timer(stun_time).timeout
	stop_stun()

func stop_stun():
	stunned = false
	hurt.monitoring = true
	$AnimatedSprite2D.modulate = Color("ffffff")
	$Stun.visible = false

func spawn():
	var respawn_point_array = get_tree().get_nodes_in_group("respawn_point")
	var player_ref = get_tree().get_first_node_in_group("player1")
	var shadow_res: Vector2
	for i in respawn_point_array: #respawn punkt für shadow wird gewählt
		if i.global_position.x - player_ref.global_position.x > 400:
			if shadow_res.x > i.global_position.x or shadow_res.x == 0:
				shadow_res = i.global_position
	
	global_position = Vector2(0, 2000)
	
	var shadow = shadow_scene.instantiate()
	shadow.global_position = shadow_res + Vector2(200,0) #+vector um bug zu beheben bei dem death anim 2 mal spielt (genauer grund unbekannt)
	get_tree().current_scene.call_deferred("add_child", shadow)
	player_ref.shadow_ref = shadow
	
	queue_free()


func _on_dash_timer_timeout() -> void:
	dashing = false
	await get_tree().create_timer(0.25).timeout
	dash_allowed = true


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player1"):
		scream.connect(body.stun)

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("player1"):
		scream.disconnect(body.stun)


func _on_jump_height_timer_timeout() -> void:
	if !Input.is_action_pressed("ui_up"):
		if velocity.y < -200:
			velocity.y = -200
			jump_timer.stop()
	elif is_on_floor():
		jump_timer.stop()


func _on_buffering_timer_timeout() -> void:
	if buffered_input == "jump":
		if coyote < 0.1:
			velocity.y = jump_force
			$Jump.play(1)
			jump_timer.start()
	elif buffered_input == "dash":
		if coyote < 0.1 and dash_allowed:
			dashing_action()


func _on_animated_sprite_2d_animation_finished() -> void:
	if sprite.animation == "spawn":
		respawning = false
		sprite.modulate = Color("ffffff")
