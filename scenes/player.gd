extends CharacterBody3D

@onready var camera: Camera3D = $Camera

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

@export var sensitivity := 0.005


func _enter_tree() -> void:
	# Set authority over the correct player
	set_multiplayer_authority(name.to_int())

func _ready() -> void:
	if not is_multiplayer_authority():
		return
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	camera.current = true


func _unhandled_input(event: InputEvent) -> void:
	if not is_multiplayer_authority():
		return
		
	if event is InputEventMouseMotion:
		self.rotate_y(-event.relative.x * sensitivity)
		camera.rotate_x(-event.relative.y * sensitivity)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-85), deg_to_rad(85))


func _physics_process(delta: float) -> void:
	# Ignore if not the player
	if not is_multiplayer_authority():
		return

	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
