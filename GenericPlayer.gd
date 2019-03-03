extends KinematicBody2D

# This demo shows how to build a kinematic controller.

export (PackedScene) var TestObject

# Member variables
const GRAVITY = 500.0 # pixels/second/second

# Angle in degrees towards either side that the player can consider "floor"
const FLOOR_ANGLE_TOLERANCE = 40
const WALK_FORCE = 600
const AIR_FORCE = 300
const WALK_MIN_SPEED = 10
const WALK_MAX_SPEED = 200
const STOP_FORCE = 5000
const AIR_STOP_FORCE = 100
const JUMP_SPEED = 300
const DOUBLE_JUMP_SPEED = 200
const JUMP_GATE_SPEED = 75
const JUMP_MAX_AIRBORNE_TIME = 0.2

const SLIDE_STOP_VELOCITY = 1.0 # one pixel/second
const SLIDE_STOP_MIN_TRAVEL = 1.0 # one pixel

var velocity = Vector2(0,0)
var on_air_time = 100
var jumping = false
var try_double_jumping = false
var double_jumping = false
var dejumping = false

var prev_jump_pressed = false
var prev_up = false
var attackObj
var direction = "right"
var origPos = Vector2(-1,-1)

var left  = false
var right = false
var up    = false
var down    = false
var jump  = false 
var fire  = false

var storedCollision

# State timers
var attacking = 0
var justAttacked = 0
var stun = 0
var preFly = 0
var fly = 0
var waitBounce = 0

# Damage
var damagePercent = 0
var flyDirection = 0
var flySpeed = 0

onready var sprite = get_node("sprite")

func attack():
	attackObj = get_node("TestObject")
	if Input.is_action_pressed("move_left"):
		attackObj.start(-10)
	if Input.is_action_pressed("move_right"):
		attackObj.start(10)
		
	
func _init():
	starInit()
	
func starInit():
	print("Default player initialization")

func _physics_process(delta):
	# Create forces
	var force = Vector2(0, GRAVITY)
	getInput();
	
	# Stun: do not allow movement while stunned
	if stun > 0:
		sprite.position = Vector2(origPos.x + rand_range(-3,3), origPos.y + rand_range(-3,3))
		stun -= delta
		# Finished stun
		if stun <= 0:
			sprite.position = Vector2(0,0)
			velocity.x = 2 * flySpeed * sin(flyDirection)
			velocity.y = -flySpeed * cos(flyDirection)
			fly = preFly
			print(str(velocity.x) + "," + str(velocity.y))
		return
	
	# FlyStun: block control, but continue to move and collide
	if fly > 0:
		# Tiny delay before bouncing
		if waitBounce > 0:
			sprite.position = Vector2(origPos.x + rand_range(-3,3), origPos.y + rand_range(-3,3))
			waitBounce -= delta
			if waitBounce <= 0:
				sprite.position = Vector2(0,0)
				velocity = velocity.bounce(storedCollision.normal)
		else:
			var collision = move_and_collide(Vector2(velocity.x / 30, velocity.y / 15))
			fly -= delta
			if collision:
				waitBounce = 0.1
				storedCollision = collision
			
		return
	var stop = true
	
	# Walking  (actually dashing for now)
	if justAttacked <= 0:
		if on_air_time >= JUMP_MAX_AIRBORNE_TIME: # In the air
			if left:
				if velocity.x > -WALK_MAX_SPEED:
					force.x -= AIR_FORCE
					stop = false
			elif right:
				if velocity.x < WALK_MAX_SPEED:
					force.x += AIR_FORCE
					stop = false
		else:
			if left:
				if velocity.x > -WALK_MAX_SPEED:
					force.x -= WALK_FORCE
					velocity.x = -WALK_MAX_SPEED
					stop = false
			elif right:
				if velocity.x < WALK_MAX_SPEED:
					force.x += WALK_FORCE
					velocity.x = WALK_MAX_SPEED
					stop = false
			
	else:
		justAttacked -= delta
			
	# Allow reversing direction only when on ground
	if on_air_time < JUMP_MAX_AIRBORNE_TIME:
		if left:
			direction = "left"
		if right:
			direction = "right"
			
	if direction == "left":
		get_node("Sprite").set_flip_h(true)
	elif direction == "right":
		get_node("Sprite").set_flip_h(false)
	
	
	if stop:
		var vsign = sign(velocity.x)
		var vlen = abs(velocity.x)
		
		if not is_on_floor():
			vlen -= AIR_STOP_FORCE * delta
		else:
			vlen -= STOP_FORCE * delta
		if vlen < 0:
			vlen = 0
		
		velocity.x = vlen * vsign
	
	# Integrate forces to velocity
	velocity += force * delta	
	# Integrate velocity into motion and move
	velocity = move_and_slide(velocity, Vector2(0, -1))
	
	
	
	if is_on_floor():
		on_air_time = 0
		double_jumping = false
		dejumping = false
		touch_ground()
		
	if on_air_time >= JUMP_MAX_AIRBORNE_TIME:
		# Air state
		# Handle jumping
		if jump and not prev_jump_pressed:
			air_jump()
		
		# Handle attacking
		if attacking <= 0 and fire:
			if left or right:
				air_side()
			elif up:
				air_up()
			elif down:
				air_down()
			else:
				air_neutral()
		if attacking > 0:
			attacking -= delta
	else:
		# Ground state
		# Handle jumping
		if jump and not prev_jump_pressed:
			ground_jump()
		
		# Handle attacking
		if attacking <= 0 and fire:
			if left or right:
				ground_side()
			elif up:
				ground_up()
			elif down:
				ground_down()
			else:
				ground_neutral()
		if attacking > 0:
			attacking -= delta
	
	if jumping and velocity.y > 0:
		# If falling, no longer jumping
		jumping = false
	
	if jumping and not jump and not dejumping:
		velocity.y = -JUMP_GATE_SPEED
		dejumping = true
	
	on_air_time += delta
	prev_jump_pressed = jump

func hit(origin, type, damage, direction, force, hitStun, flyStun):
	print(type)
	stun += hitStun
	damagePercent += damage
	flyDirection = direction
	flySpeed = force
	preFly = flyStun
	
func out():
	print("out")
	position = get_parent().initPos
	velocity = Vector2(0,0)

func ground_neutral():
	print("Error: player did not override ground_neutral!")
func ground_side():
	print("Error: player did not override ground_side!")
func ground_up():
	print("Error: player did not override ground_up!")
func ground_down():
	print("Error: player did not override ground_down!")
func ground_jump():
	print("Error: player did not override ground_jump!")
	
func air_neutral():
	print("Error: player did not override air_neutral!")
func air_side():
	print("Error: player did not override air_side!")
func air_up():
	print("Error: player did not override air_up!")
func air_down():
	print("Error: player did not override air_down!")
func air_jump():
	print("Error: player did not override air_jump!")
	
	
func touch_ground():
	print("Error: player did not override touch_ground!")