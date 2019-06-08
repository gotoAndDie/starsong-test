const JUMP_SPEED = 300
const DOUBLE_JUMP_SPEED = 200
var double_jumping = false

var SwordArc
var RisingArc

func starInit(character):
	print("Estella")
	SwordArc = load("res://Moves/SwordArc.tscn")
	RisingArc = load("res://Moves/RisingArc.tscn")
	character.GRAVITY = 500.0 # pixels/second/second
	# Angle in degrees towards either side that the player can consider "floor"
	character.FLOOR_ANGLE_TOLERANCE = 30
	character.WALK_FORCE = 600
	character.AIR_FORCE = 300
	
	character.WALK_MIN_SPEED = 10
	character.WALK_MAX_SPEED = 200
	character.AIR_INVERT_FORCE = 500
	
	character.STOP_FORCE = 500
	character.AIR_STOP_FORCE = 100
	
	character.JUMP_SPEED = 300
	character.DOUBLE_JUMP_SPEED = 200
	character.JUMP_GATE_SPEED = 75
	character.FALL_GATE_SPEED = 300
	character.FAST_FALL_GATE_SPEED = 320
	
	character.SLIDE_STOP_VELOCITY = 1.0 # one pixel/second
	character.SLIDE_STOP_MIN_TRAVEL = 1.0 # one pixel

func ground_neutral(character):
	print("ground neutral")
	
	var attackObj = SwordArc.instance()
	var attackProperty = AttackProperty.new().init(3, 45, 100, 0.1, 0.1)
	character.add_child(attackObj)
	if character.direction == "left":
		attackObj.start(-10, 0, attackProperty, 0.1)
	else: 
		attackObj.start(10, 0, attackProperty, 0.1)
	character.attackLagFrame = 0.2
	character.movementLagFrame = 0.2

func ground_side(character):
	print("ground side")
	var attackProperty = AttackProperty.new().init(7, 45, 200, 0.1, 0.1)
	
	var attackObj = SwordArc.instance()
	character.add_child(attackObj)
	if character.left:
		attackObj.start(-10, 0, attackProperty, 0.3)
	if character.right:
		attackObj.start(10, 0, attackProperty, 0.3)
	character.attackLagFrame = 0.5
	character.movementLagFrame = 0.5

func ground_up(character):
	print("ground up")
	var attackObj = RisingArc.instance()
	var attackProperty = AttackProperty.new().init(7, 75, 200, 0.1, 0.1)
	character.add_child(attackObj)
	if character.direction == "left":
		attackObj.start(-15, attackProperty, 0.5)
	else:
		attackObj.start(15, attackProperty, 0.5)
	character.attackLagFrame = 0.6
	character.movementLagFrame = 0.3
	character.freeFall = true
	
func ground_down(character):
	print("ground down")

func ground_jump(character):
	
	var derot_velocity = character.velocity.rotated(-character.rotation)
	derot_velocity.y -= JUMP_SPEED
	character.velocity = derot_velocity.rotated(character.rotation)
	
	
	character.jumping = true
	character.fast_fall_on = true
	character.on_air_time = character.JUMP_MAX_AIRBORNE_TIME
	print("ground jump")
	
func air_neutral(character):
	print("air neutral")

func air_side(character):
	print("air side")
	var attackObj = SwordArc.instance()
	var attackProperty = AttackProperty.new().init(7, 45, 200, 0.1, 0.1)
	character.add_child(attackObj)
	if character.left:
		attackObj.start(-10, 0, attackProperty, 0.3)
	if character.right:
		attackObj.start(10, 0, attackProperty, 0.3)
	character.attackLagFrame = 0.5

func air_up(character):
	print("air up")
	var attackObj = RisingArc.instance()
	var attackProperty = AttackProperty.new().init(7, 75, 200, 0.1, 0.1)
	character.add_child(attackObj)
	if character.direction == "left":
		attackObj.start(-15, attackProperty, 0.5)
	else:
		attackObj.start(15, attackProperty, 0.5)
	character.attackLagFrame = 0.6
	character.movementLagFrame = 0.3
	character.freeFall = true
	
func air_down(character):
	print("air down")
	
func air_jump(character):
	if character.jump and not character.prev_jump_pressed and not double_jumping:
		character.rotation = 0
		character.velocity.y = -DOUBLE_JUMP_SPEED
		double_jumping = true
		if character.left:
			character.velocity.x = -character.WALK_MAX_SPEED * character.x_factor
		elif character.right:
			character.velocity.x = character.WALK_MAX_SPEED * character.x_factor
		else:
			character.velocity.x = 0
		
func touch_ground(character):
	double_jumping = false