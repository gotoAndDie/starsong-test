extends KinematicBody2D

class_name GenericPlayer

# Default physical parameters
var GRAVITY = 500.0 # pixels/second/second
# Angle in degrees towards either side that the player can consider "floor"
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
var prev_attack_pressed = false
var prev_special_pressed = false

var attackObj
var direction = "right" # Direction character is facing, left or right
var origPos = Vector2(-1,-1)

# Button presses
var left       = false
var right      = false
var up         = false
var down       = false
var jump       = false 
var attack     = false
var special    = false
var switch     = false
var x_factor   = 0.0
var joy_l_theta     = -1       # Angle of joystick
var joy_r_theta     = -1
var joy_l_magnitude = 0
var joy_r_magnitude = 0

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
	
	# Horizontal movement
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
	if get_slide_count() > 0:
		var collision = get_slide_collision(0)
		var angle = collision.get_normal().angle() + 0.5 * PI
		
		# Do not rotate and reset rotation if you're too slow (and on a steep surface)
		if abs(derot_velocity.x) < 100 && is_on_floor() && Globals.angle_to_angle(angle, 0) < 0.5*PI:
			rotation = 0
			standing_normal = Vector2(0,1)
			
		if Globals.angle_to_angle(angle, rotation) < 0.2 * PI || Globals.angle_to_angle(angle, 0) < 0.1*PI:
			rotation = angle
			standing_normal = collision.get_normal().normalized()
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
		
	# Handle groun and air attacks
	if on_air_time >= JUMP_MAX_AIRBORNE_TIME:
		# Air state
		# Handle jumping
		if jump and not prev_jump_pressed and movementLagFrame <= 0 and !freeFall:
			air_jump()
		
		# Handle attacking
		if attack and not prev_attack_pressed and !freeFall:
			air_normal()
			
		if special and not prev_special_pressed and !freeFall:
			air_special()
	else:
		# Ground state
		# Handle jumping
		if jump and not prev_jump_pressed and movementLagFrame <= 0:
			ground_jump()
		
		# Handle attacking
		if attack and not prev_attack_pressed:
			ground_normal()
			
		if special and not prev_special_pressed:
			ground_special()
			
	prev_attack_pressed = attack
	prev_special_pressed = special
	
	if jumping and velocity.y > 0:
		# If falling, no longer jumping
		jumping = false
	
	if jumping and not jump and not dejumping:
		velocity.y = -JUMP_GATE_SPEED
		dejumping = true
	
	on_air_time += delta
	prev_jump_pressed = jump
	
	
	# Run any other operations injected by the specific character
	# Such as handling attack lag
	loop_inject(delta)
	
	# Handle 
	if hitProperty != null:
		if hitProperty.delayFrames > 0:
			hitProperty.delayFrames -= delta
		else:
			procHit(hitType, hitProperty)
			hitProperty = null

var hitType = null
var hitProperty = null
func hit(origin, type, attackProperty:AttackProperty):
	hitType = type
	hitProperty = attackProperty
	
func procHit(type, attackProperty:AttackProperty):
	print(type)
	stun += attackProperty.stun
	damagePercent += attackProperty.damage
	flyDirection = attackProperty.direction
	flySpeed = attackProperty.force
	preFly = attackProperty.flyStun
	freeFall = false
func launch():
	pass
	
func out():
	print("out")
	position = get_parent().initPos
	velocity = Vector2(0,0)

func ground_normal():
	print("Error: player did not override ground_normal!")
func ground_special():
	print("Error: player did not override ground_special!")
func ground_jump():
	print("Error: player did not override ground_jump!")
	

func air_normal():
	print("Error: player did not override air_normal!")
func air_special():
	print("Error: player did not override air_special!")
func air_jump():
	print("Error: player did not override air_jump!")
	
	
func touch_ground():
	print("Error: player did not override touch_ground!")
	
func loop_inject(delta):
	pass