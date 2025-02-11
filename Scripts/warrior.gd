extends CharacterBody3D

var can_move = true
var weapon_to_spawn
var weapon_to_drop
var is_jumping = false
var is_attacking = false

@export var speed = 5.0
@export var jump_velocity = 4.5
@export var gravity = 9.8
@export var horiz_sens = 0.004
@export var vert_sens = 0.004

@onready var neck := $Armature/Skeleton3D/Neck
@onready var warrior = $Armature
@onready var camera := $Armature/Skeleton3D/Neck/Camera3D
@onready var reach = $Armature/Skeleton3D/Neck/Camera3D/Reach
@onready var hand = $Armature/Skeleton3D/Arm/Hand
@onready var animation_player = $AnimationPlayer
@onready var hair = $Armature/Skeleton3D/Face__ncl1_29002
@onready var body = $Armature/Skeleton3D/Warrior_Body__ncl1_29005
@onready var L_pad = $Armature/Skeleton3D/ShoulderPadL__ncl1_29000
@onready var R_pad = $Armature/Skeleton3D/ShoulderPadR__ncl1_29001

@onready var greatsword_hr = preload("res://Resources/great_sword_hr.tscn")
@onready var greatsword = preload("res://Resources/great_sword.tscn")
@onready var hammer_hr = preload("res://Resources/hammer_hr.tscn")
@onready var hammer = preload("res://Resources/hammer.tscn")

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	camera.current = is_multiplayer_authority()
	if is_multiplayer_authority():  # This checks if this is the local player
		hide_model_for_local_player()

	animation_player.animation_finished.connect(_on_animation_finished)

func _on_animation_finished(anim_name):
	if anim_name == "GreatSwordSlash":  # Replace with the correct attack animation name
		is_attacking = false

# Hide the model for the local player's camera
func hide_model_for_local_player():
	# Set the model's visibility to false for the local camera
	hair.visible = false
	body.visible = false
	L_pad.visible = false
	R_pad.visible = false

	# Exclude layer 20 from being rendered by the local camera
	camera.cull_mask &= ~(1 << 20)  # Exclude layer 20 for the camera

func HandlePickUpDrop():
	# Only proceed if the reach is colliding with something
	if reach.is_colliding():
		var collider = reach.get_collider()
		if collider:
			if collider.get_name() == "GreatSword":
				weapon_to_spawn = greatsword_hr.instantiate()
			elif collider.get_name() == "Hammer":
				weapon_to_spawn = hammer_hr.instantiate()
			else:
				weapon_to_spawn = null

		if hand.get_child_count() > 0:
			var current_weapon = hand.get_child(0)
			if current_weapon.get_name() == "GreatSword HR":
				weapon_to_drop = greatsword.instantiate()
			elif current_weapon.get_name() == "Hammer HR":
				weapon_to_drop = hammer.instantiate()
		else:
			weapon_to_drop = null

		# Drop the weapon if holding one, and pick up the new one
		if weapon_to_spawn != null:
			DropWeapon()
			hand.add_child(weapon_to_spawn)

		# Destroy the collider object (i.e., the weapon on the ground)
		if weapon_to_spawn != null:
			collider.queue_free()

func DropWeapon():
	if weapon_to_drop != null:
		# Drop the currently held weapon
		get_parent().add_child(weapon_to_drop)
		weapon_to_drop.global_transform = hand.global_transform
		weapon_to_drop.dropped = true
		hand.get_child(0).queue_free()

func _enter_tree():
	set_multiplayer_authority(name.to_int())

func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("Interact"):
		HandlePickUpDrop()
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			rotate_y(-event.relative.x * horiz_sens)
			camera.rotate_x(-event.relative.y * vert_sens)
			camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-60), deg_to_rad(60))

func _physics_process(delta: float) -> void:
	if is_multiplayer_authority():
		if can_move:
			# Declare input_dir and direction at the start
			var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
			var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

			# Add the gravity.
			if not is_on_floor():
				velocity.y += -gravity * delta
				# If the player is not on the ground and wasn't already jumping, play the jump animation
				if not is_jumping:
					is_jumping = true
					if hand.get_child_count() > 0:
						animation_player.play("GreatSwordJump", 1)
					else:
						animation_player.play("Jump", 1)

			# Handle jump.
			if Input.is_action_just_pressed("jump") and is_on_floor():
				velocity.y = jump_velocity
				if not is_jumping:
					is_jumping = true
					if hand.get_child_count() > 0:
						animation_player.play("GreatSwordJump", 1)
					else:
						animation_player.play("Jump", 1)  # Play jump animation when the jump key is pressed
			
			if Input.is_action_just_pressed("Attack") and hand.get_child_count() > 0 and not is_attacking:
				is_attacking = true
				animation_player.play("GreatSwordSlash", 1)

			# Check if the player is on the ground
			if is_on_floor() and not is_attacking:
				if is_jumping:  # Transition back to idle or walking after landing
					is_jumping = false
				if is_attacking:
					is_attacking = false
					# Play an idle or walking animation depending on movement
				if input_dir.y > 0:
					if hand.get_child_count() > 0:
						animation_player.play("GreatSwordWalk", 1)
					else:
						animation_player.play("Walking", 1)
				elif input_dir.y < 0:
					if hand.get_child_count() > 0:
						animation_player.play("GreatSwordWalkBack", 1)
					else:
						animation_player.play("StandingRunBack", 1)
				elif input_dir.x > 0:
					if hand.get_child_count() > 0:
						animation_player.play("GreatSwordStrafeRight", 1)
					else:
						animation_player.play("RightStrafeWalking", 1)
				elif input_dir.x < 0:
					if hand.get_child_count() > 0:
						animation_player.play("GreatSwordStrafeLeft", 1)
					else:
						animation_player.play("LeftStrafeWalking", 1)
				else:
					if hand.get_child_count() > 0:
						animation_player.play("GreatSwordIdle", 1)
					else:
						animation_player.play("Idle", 1)

			# Movement handling
			if direction:
				velocity.x = direction.x * speed
				velocity.z = direction.z * speed
			else:
				velocity.x = move_toward(velocity.x, 0, speed)
				velocity.z = move_toward(velocity.z, 0, speed)

			move_and_slide()
