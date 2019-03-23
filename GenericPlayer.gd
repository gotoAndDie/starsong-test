extends KinematicBody2D


# Default physical parameters
var GRAVITY = 500.0 # pixels/second/second
# Angle in degrees towards either side that the player can consider "floor"
var FLOOR_ANGLE_TOLERANCE = 30
var WALK_FORCE = 600
var AIR_FORCE = 300

var WALK_MIN_SPEED = 10
var WALK_MAX_SPEED = 200
var AIR_INVERT_FORCE = 500

var STOP_FORCE = 5000
var AIR_STOP_FORCE = 100

var JUMP_SPEED = 300
var DOUBLE_JUMP_SPEED = 200
var JUMP_GATE_SPEED = 75
var FALL_GATE_SPEED = 300
var FAST_FALL_GATE_SPEED = 500
var FAST_FALL_FORCE = 200

var SLIDE_STOP_VELOCITY = 1.0 # one pixel/second
var SLIDE_STOP_MIN_TRAVEL = 1.0 # one pixel


const JUMP_MAX_AIRBORNE_TIME = 0.2


var velocity = Vector2(0,0)
var on_air_time = 100
var jumping = false
var try_double_jumping = false
var double_jumping = false
var dejumping = false
var fast_fall_on = false
var freeFall = false

var prev_jump_pressed = false
var prev_up = false
var attackObj
var direction = "right"
var origPos = Vector2(-1,-1)

var left    = false
var right   = false
var up      = false
var down    = false
var jump    = false 
var fire    = false
var special = false

var storedCollision

# State timers
var attackLagFrame = 0
var movementLagFrame = 0
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
	
func getInput():
	print("Error! getInput not overridden!")

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
	if movementLagFrame <= 0:
		if on_air_time >= JUMP_MAX_AIRBORNE_TIME: # In the air
			if left:
				if velocity.x > -WALK_MAX_SPEED:
					force.x -= AIR_FORCE
					stop = false
				if velocity.x > 0: # Trying to stop
					force.x -= AIR_INVERT_FORCE
					stop = false
			elif right:
				if velocity.x < WALK_MAX_SPEED:
					force.x += AIR_FORCE
					stop = false
				if velocity.x < 0: # Trying to stop
					force.x += AIR_INVERT_FORCE
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
			
		# Allow reversing direction only when on ground
		if on_air_time < JUMP_MAX_AIRBORNE_TIME:
			if left:
				direction = "left"
			if right:
				direction = "right"
			
	else:
		movementLagFrame -= delta
			
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
	
	# Increase gravity when down is held
	if not is_on_floor() and down and (fast_fall_on or freeFall):
		velocity.y = FAST_FALL_GATE_SPEED
	# Integrate forces to velocity
	velocity += force * delta
	
	# Enforce maximum fall speed
	if not is_on_floor() and velocity.y > FALL_GATE_SPEED and fast_fall_on:
		velocity.y = FALL_GATE_SPEED
		if down:
			velocity.y = FAST_FALL_GATE_SPEED
		
	# Integrate velocity into motion and move
	velocity = move_and_slide(velocity, Vector2(0, -1))
	
	
	
	if is_on_floor() && on_air_time >= JUMP_MAX_AIRBORNE_TIME:
		double_jumping = false
		dejumping = false
		fast_fall_on = false
		freeFall = false
		touch_ground()

	if is_on_floor():
		on_air_time = 0
		
	if on_air_time >= JUMP_MAX_AIRBORNE_TIME:
		# Air state
		# Handle jumping
		if jump and not prev_jump_pressed and movementLagFrame <= 0 and !freeFall:
			print("um")
			air_jump()
		
		# Handle attacking
		if attackLagFrame <= 0 and fire and !freeFall:
			if left or right:
				air_side()
			elif up:
				air_up()
			elif down:
				air_down()
			else:
				air_neutral()
		if attackLagFrame > 0:
			attackLagFrame -= delta
	else:
		# Ground state
		# Handle jumping
		if jump and not prev_jump_pressed and movementLagFrame <= 0:
			ground_jump()
		
		# Handle attacking
		if attackLagFrame <= 0 and fire:
			if left or right:
				ground_side()
			elif up:
				ground_up()
			elif down:
				ground_down()
			else:
				ground_neutral()
		if attackLagFrame > 0:
			attackLagFrame -= delta
	
	if jumping and velocity.y > 0:
		# If falling, no longer jumping
		jumping = false
	
	if jumping and not jump and not dejumping:
		velocity.y = -JUMP_GATE_SPEED
		dejumping = true
	
	on_air_time += delta
	prev_jump_pressed = jump

func hit(origin, type, attackProperty:AttackProperty):
	print(type)
	stun += attackProperty.stun
	damagePercent += attackProperty.damage
	flyDirection = attackProperty.direction
	flySpeed = attackProperty.force
	preFly = attackProperty.flyStun
	freeFall = false
	
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