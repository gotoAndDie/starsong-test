extends KinematicBody2D


# Default physical parameters
var GRAVITY = 500.0 # pixels/second/second
# Angle in degrees towards either side that the player can consider "floor"
var FLOOR_ANGLE_TOLERANCE = 180
var WALK_FORCE = 1200
var AIR_FORCE = 300

var WALK_MIN_SPEED = 10
var WALK_MAX_SPEED = 200
var AIR_INVERT_FORCE = 500

var STOP_FORCE = 500
var AIR_STOP_FORCE = 100

var JUMP_SPEED = 300
var DOUBLE_JUMP_SPEED = 200
var JUMP_GATE_SPEED = 75
var FALL_GATE_SPEED = 300
var FAST_FALL_GATE_SPEED = 400
var FAST_FALL_FORCE = 200

var SLIDE_STOP_VELOCITY = 1.0 # one pixel/second
var SLIDE_STOP_MIN_TRAVEL = 1.0 # one pixel

# Maximum time one can be in the air while still being able to jump
const JUMP_MAX_AIRBORNE_TIME = 0.1

# Maximum time one can be in the air while rotated
const ROTATION_MAX_AIRBORNE_TIME = 1

var velocity = Vector2(0,0)
var standing_normal = Vector2(0,1)
var on_air_time = 100
var rotated_air_time = 100
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

# Button presses
var left     = false
var right    = false
var up       = false
var down     = false
var jump     = false 
var fire     = false
var special  = false
var x_factor = 0.0
var theta    = -1       # Angle of joystick

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
	var derot_velocity = velocity.rotated(-rotation)
	
	if on_air_time >= JUMP_MAX_AIRBORNE_TIME:
		force = force.rotated(-rotation)
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
		if !is_on_floor(): # In the air
			if left:
				if derot_velocity.x > -WALK_MAX_SPEED:
					force.x -= AIR_FORCE * x_factor
				stop = false
				if derot_velocity.x > 0: # Trying to stop
					force.x -= AIR_INVERT_FORCE * x_factor
				stop = false
			elif right:
				if derot_velocity.x < WALK_MAX_SPEED:
					force.x += AIR_FORCE * x_factor
				stop = false
				if derot_velocity.x < 0: # Trying to stop
					force.x += AIR_INVERT_FORCE * x_factor
				stop = false
		else:
			if left:
				if derot_velocity.x > -WALK_MAX_SPEED * x_factor * 0.5 * (1 + cos(rotation)):
					force.x -= WALK_FORCE * x_factor * 0.5 * (1 + cos(rotation))
					# velocity.x = -WALK_MAX_SPEED * x_factor
				stop = false
			elif right:
				if derot_velocity.x < WALK_MAX_SPEED * x_factor * 0.5 * (1 + cos(rotation)):
					force.x += WALK_FORCE * x_factor * 0.5 * (1 + cos(rotation))
					# velocity.x = WALK_MAX_SPEED * x_factor
				stop = false
			
		# Allow reversing direction only when on ground
		if is_on_floor():
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
		var vsign = sign(derot_velocity.x)
		var vlen = abs(derot_velocity.x)
		
		if not is_on_floor():
			vlen -= AIR_STOP_FORCE * delta
		else:
			vlen -= STOP_FORCE * delta
		if vlen < 0:
			vlen = 0
		
		derot_velocity.x = vlen * vsign
		velocity = derot_velocity.rotated(rotation)
	
	# Set player angle according to ground
	var collision = get_slide_collision(0)
	if collision != null:
		standing_normal = collision.get_normal().normalized()
		var angle = collision.get_normal().angle() + 0.5 * PI
		
		# Do not rotate and reset rotation if you're too slow (and on a steep surface)
		if abs(derot_velocity.x) < 100 && is_on_floor() && Globals.angle_to_angle(angle, 0) < 0.5*PI:
			rotation = 0
			pass
			
		if Globals.angle_to_angle(angle, rotation) < 0.2 * PI || Globals.angle_to_angle(angle, 0) < 0.1*PI:
			rotation = angle
		rotated_air_time = ROTATION_MAX_AIRBORNE_TIME
		
			
	# However, if not on ground, reset rotation after a period of time
	if rotation != 0:
		rotated_air_time -= delta
		
	if rotated_air_time <= 0:
		rotation = 0
		
		
		
	
	# Increase gravity and reset rotation when down is held
	if not is_on_floor() and down and (fast_fall_on or freeFall):
		rotation = 0
		velocity.y = FAST_FALL_GATE_SPEED
	# Integrate forces to velocity
	
	force = force.rotated(rotation) # Rotate all forces according to rotation
	velocity += force * delta
	
	# Enforce maximum fall speed
	if not is_on_floor() and velocity.y > FALL_GATE_SPEED and fast_fall_on:
		velocity.y = FALL_GATE_SPEED
		if down:
			velocity.y = FAST_FALL_GATE_SPEED
		
	# Integrate velocity into motion and move
	velocity = move_and_slide(velocity, standing_normal)
	
	
	
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