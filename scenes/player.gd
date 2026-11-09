extends CharacterBody3D

@onready var camera: Camera3D = $Camera
@onready var animation_player: AnimationPlayer = $playermodel/AnimationPlayer
@onready var mesh: MeshInstance3D = $playermodel/Armature/Skeleton3D/Mesh
@export var chosen_colour:= Color(1, 0, 0, 1)

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
	animate("idle")
	mesh.get_active_material(0).set_albedo(Color(chosen_colour)) #OMG IT WORKS


func _unhandled_input(event: InputEvent) -> void:
	if not is_multiplayer_authority():
		return
		
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
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
		animate("walk")
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		animate("idle")

	move_and_slide()

func _process(delta: float) -> void:
	if not is_multiplayer_authority():
		return
	# Use escape to capture & release the mouse. 
	if Input.is_action_just_pressed("escape"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		elif Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func animate(animation: String):
	if not is_multiplayer_authority():
		return
	if animation == "idle":
		animation_player.play("idle")
	if animation == "walk":
		animation_player.play("walk")


func _on_color_picker_color_changed(colour: Color) -> void:
	if not is_multiplayer_authority():
		return
	change_colour(colour)


func change_colour(colour: Color):
	if not is_multiplayer_authority():
		return
	chosen_colour = colour
	mesh.get_active_material(0).set_albedo(Color(chosen_colour))
