extends CharacterBody2D

@onready var sprite = $AnimatedSprite2D
@onready var dash_timer = $DashTimer
@onready var jump_timer = $JumpHeightTimer
@onready var buffering_timer = $JumpBufferingTimer
@onready var dash_collision = $DashCollision
@onready var default_collision = $NormalCollision
@onready var lichtkegel: Area2D = $Lichtkegel

signal flashlight

var pausemenu = preload("res://Szene/PauseMenu.tscn")

# noch nicht getestet
var jump_force = -1800
var direction
var speed = 900

var dash_speed = 1700
var dashing = false
var dash_allowed = true
var dash_direction = 1

var shadow_ref
var respawn_ref

var buffering = false
var buffered_input: String

var light_timer = 0
var lichtkegel_sichtbar: bool = true

var enemy_sight: bool = false

var freeze = true
var stunned = false
var stun_time = 1.5

var coyote = 0

var next_to_wall = false

var hitcounter = 0

var color_array = ["FFFFFF", "FFA500"]

var death = "death"

func _ready() -> void:
	shadow_ref = get_tree().get_first_node_in_group("shadow")
	respawn_ref = get_tree().get_first_node_in_group("first").global_position
	
	activate_flashlight()
	
	sprite.play("respawn")

func _process(delta: float) -> void:
	#animations
	if coyote == 0 and not freeze:
		if dashing:
			sprite.play("dash")
		elif direction == 0:
			sprite.play("default")
			$Lichtkegel.position = Vector2(-7.5,-3.5)
		elif direction != 0:
			sprite.play("walk")
			$Lichtkegel.position = Vector2(0.4,-1.3)

func _physics_process(delta: float) -> void:
	#generates gravity for player	
	if is_on_floor() or $RayCast2D3.is_colliding() or $RayCast2D2.is_colliding() or $RayCast2D.is_colliding():
		coyote = 0
	elif not freeze:
		coyote += delta
		if velocity.y > 0:
			velocity += get_gravity() * delta * 6.25
		else:
			velocity += get_gravity() * delta * 7
	
	if stunned == false and not freeze:
		#gets direction imput
		if !dashing:
			direction = Input.get_axis("ui_a", "ui_d")
		
		#checks direction to flip sprite
		if direction < 0:
			self.scale.y = -2.25
			self.rotation_degrees = 180
			dash_direction = -1
		elif direction > 0:
			self.scale.y = 2.25
			self.rotation_degrees = 0
			dash_direction = 1
		
	#generates character movement
		if direction:
			if dashing:
				velocity.x = dash_speed * dash_direction
			else:
				velocity.x = speed * direction
		else:
			if dashing:
				velocity.x = dash_speed * dash_direction
			else:
				velocity.x = move_toward(velocity.x, 0, speed)
		
		#fast fall
		if Input.is_action_pressed("ui_s") and coyote > 0:
			velocity += get_gravity() * delta * 400
	else:
		velocity.x = 0
	
	move_and_slide()
	
	
	
	if dashing and $collisionahead.get_collider() is TileMapLayer:
		next_to_wall = true
		var fx = $collisionahead.get_collision_point()
		fx = Vector2i(fx)
		var tml: TileMapLayer = $collisionahead.get_collider()
		var cell_coords = tml.local_to_map(fx)
		var data: TileData = tml.get_cell_tile_data(cell_coords)
		if data != null:
			if data.get_custom_data("slope") == true:
				velocity.y = -100
				next_to_wall = false
	else:
		next_to_wall = false
	
	if next_to_wall and dashing:
		velocity.x = 0
		dash_timer.stop()
		_on_timer_timeout()
	
	#if lichtkegel_sichtbar and enemy_sight:
	#	light_timer += delta
	#	if light_timer > 0.25:
	#		$Stun.play()
	#		lichtkegel.modulate = Color("ffff00")
	#		flashlight.emit()
	#		lichtkegel.monitoring = false
	#		await get_tree().create_timer(0.2).timeout
	#		lichtkegel.modulate = Color("ffffff")
	#		lichtkegel.hide()
	#		Cooldown.on_cooldown["flashlight"][0] = true
	#elif light_timer > 0:
	#	light_timer -= 0.1*delta
	#else:
	#	light_timer = 0


func _input(event: InputEvent) -> void:
	if stunned == false and freeze == false:
		#makes player jump when on floor
		if Input.is_action_just_pressed("ui_w"):
			if coyote < 0.1:
				jump_timer.start()
				velocity.y = jump_force
				sprite.play("jump")
				$Lichtkegel.position = Vector2(4.4,-7.5)
				$Jump.play()
			else:
				buffering_timer.start()
				buffered_input = "jump"
			
		if Input.is_action_pressed("ui_flashlight") and lichtkegel_sichtbar: #and Cooldown.on_cooldown["flashlight"][0] == false 
			lichtkegel_sichtbar = false
			lichtkegel.modulate = Color("ffff00")
			if enemy_sight == true:
				hitcounter += 1
				if hitcounter == 2:
					hitcounter = 0
					flashlight.connect(shadow_ref.stun)
					flashlight.emit()
					flashlight.disconnect(shadow_ref.stun)
					$FlashlightTimer.wait_time = 2
			else:
				if hitcounter > 0:
					hitcounter -= 1
			lichtkegel.monitoring = false
			await get_tree().create_timer(0.2).timeout
			deactivate_flashlight()
			$FlashlightTimer.start()
			
			#if lichtkegel_sichtbar == false:
			#	$Flashlight.play()
			#	lichtkegel.show()
			#	lichtkegel.monitoring = true
			#	lichtkegel_sichtbar = true
		
		#elif Input.is_action_just_released("ui_flashlight"):
		#	deactivate_flashlight()
		
		if Input.is_action_just_pressed("ui_s") and !next_to_wall:
			if coyote < 0.1 and dash_allowed == true:
				dash()
			else:
				buffering_timer.start()
				buffered_input = "dash"

func dash():
	deactivate_flashlight()
	dash_allowed = false
	$Slide.play()
	dashing = true
	dash_collision.disabled = false
	$CharacterBody2D/HeadCollision.disabled = false
	default_collision.disabled = true
	sprite.offset = Vector2(90, 160)
	dash_timer.start()

#respawn
func respawn():
	freeze = true
	deactivate_flashlight()
	sprite.play(death)
	velocity.y = 0

#dash timer
func _on_timer_timeout() -> void:
	dashing = false
	default_collision.disabled = false
	dash_collision.disabled = true
	$CharacterBody2D/HeadCollision.disabled = true
	sprite.offset = Vector2(0, 0)
	activate_flashlight()
	await get_tree().create_timer(0.5).timeout
	dash_allowed = true


func _on_lichtkegel_body_entered(body: Node2D) -> void:
	if body.is_in_group("shadow"):
		if !body.respawning:
			enemy_sight = true

func _on_lichtkegel_body_exited(body: Node2D) -> void:
	if body.is_in_group("shadow"):
		enemy_sight = false


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

func deactivate_flashlight():
	lichtkegel.hide()
	lichtkegel.monitoring = false
	lichtkegel_sichtbar = false

func activate_flashlight():
	if sprite.animation != "death":
		lichtkegel.show()
		lichtkegel.monitoring = true
		lichtkegel_sichtbar = true


func _on_jump_height_timer_timeout() -> void:
	if !Input.is_action_pressed("ui_w"):
		if velocity.y < -200:
			velocity.y = -200
			jump_timer.stop()
	elif coyote == 0:
		jump_timer.stop()


func _on_jump_buffering_timer_timeout() -> void:
	if buffered_input == "jump" and !freeze and !stunned:
		if coyote < 0.1:
			jump_timer.start()
			velocity.y = jump_force
			sprite.play("jump")
			$Lichtkegel.position = Vector2(4.4,-7.5)
			$Jump.play()
	elif buffered_input == "dash" and !freeze and !stunned:
		if coyote < 0.1 and dash_allowed == true:
			dash()

func _on_animated_sprite_2d_animation_finished() -> void:
	if sprite.animation == "respawn":
		freeze = false
		activate_flashlight()
		death = "death"
	elif sprite.animation == "death":
		death = ""
		for i in get_tree().get_nodes_in_group("shadow_prop"):
			i.queue_free()
		global_position = respawn_ref
		shadow_ref.spawn()
		#Cooldown.on_cooldown["flashlight"][0] = false
		stun_stop()
		sprite.play("respawn")


func _on_flashlight_timer_timeout() -> void:
	activate_flashlight()
	lichtkegel.modulate = Color(color_array[hitcounter])
	$FlashlightTimer.wait_time = 0.5
