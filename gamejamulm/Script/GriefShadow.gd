extends CharacterBody2D

#var anger : ShadowBase = ShadowBase.new()
@onready var sprite = $AnimatedSprite2D
@onready var dash_timer = $DashTimer
@onready var jump_timer = $JumpHeightTimer
@onready var buffering_timer = $BufferingTimer
@onready var hurt = $Hurtbox
@onready var nav = $NavigationAgent2D

var puddle_scene = preload("res://Szene/puddle.tscn")
var shadow_scene = preload("res://Szene/GriefShadow.tscn")

var jump_force = -2000
var direction
var speed = 600

var buffered_input: String

var dash_speed = 1200
var dashing = false
var dash_allowed = true
var dash_direction = -1

var stunned = false
var stun_time

var puddle_allowed = true

var coyote = 0

func _ready() -> void:
	stun_time = 1.5
	

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
		if GameMode.GameMode == "default":
			#gets direction imput
			direction =  Input.get_axis("ui_left", "ui_right")
			
			#checks direction to flip sprite
			if direction < 0:
				sprite.flip_h = false
				dash_direction = -1
			elif direction > 0:
				sprite.flip_h = true
				dash_direction = 1
			
			
			if Input.is_action_just_pressed("ui_down"):
				if not is_on_floor():
					velocity += get_gravity() * delta * 200
		
		#generates character movement
		if direction:
			if sprite.animation != "blink":
				sprite.play("walk")
			if dashing:
				velocity.x = dash_speed * direction
			else:
				velocity.x = speed * direction
		else:
			if sprite.animation != "blink":
				sprite.play("default")
			if dashing:
				velocity.x = dash_speed * dash_direction
			else:
				velocity.x = move_toward(velocity.x, 0, speed)
		
	else:
		velocity.x = 0
		
	move_and_slide()

func _input(event: InputEvent) -> void:
	if stunned == false:
		#makes player jump when on floor
		if Input.is_action_just_pressed("ui_up"):
			if coyote < 0.1:
				velocity.y = jump_force
				$Jump.play()
				jump_timer.start()
			else:
				buffering_timer.start()
				buffered_input = "jump"
		
		if Input.is_action_just_pressed("ui_down"):
			if coyote < 0.1 and dash_allowed:
				dashing_action()
			else:
				buffering_timer.start()
				buffered_input = "dash"
		
		if Input.is_action_just_pressed("ui_ctrl") and puddle_allowed:
			puddleing()

func dashing_action():
	dashing = true
	dash_allowed = false
	dash_timer.start()
	$Dash.play()

func puddleing():
	if puddle_allowed:
		$Ability.play()
		puddle_allowed = false
		sprite.play("blink")
		var x = -100
		while x <= 100:
			var puddle = puddle_scene.instantiate() #spawns bullet
			puddle.global_position = $PuddleSpawnpoint1.global_position + Vector2(x,0) #set position to marker2D
			get_tree().current_scene.add_child(puddle) #link bullet to tree
			x += 100
		await sprite.animation_finished
		sprite.play("default")
		await get_tree().create_timer(1).timeout
		puddle_allowed = true

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	spawn()

func _on_hurtbox_body_entered(body: Node2D) -> void:
	print("hit")
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
	
	var shadow = shadow_scene.instantiate()
	shadow.global_position = shadow_res + Vector2 (300, 0) #+vector um bug zu beheben bei dem death anim 2 mal spielt (genauer grund unbekannt)
	get_tree().current_scene.call_deferred("add_child", shadow)
	player_ref.shadow_ref = shadow
	
	call_deferred("queue_free")


func _on_dash_timer_timeout() -> void:
	dashing = false
	await get_tree().create_timer(0.1).timeout
	dash_allowed = true


func _on_jump_height_timer_timeout() -> void:
	if !Input.is_action_pressed("ui_up"):
		if velocity.y < -300:
			velocity.y = -300
			jump_timer.stop()
	elif is_on_floor():
		jump_timer.stop()


func _on_buffering_timer_timeout() -> void:
	if buffered_input == "jump":
		if coyote < 0.1:
			velocity.y = jump_force
			$Jump.play()
			jump_timer.start()
	elif buffered_input == "dash":
		if coyote < 0.1 and dash_allowed:
			dashing_action()
