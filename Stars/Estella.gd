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
	
	character.STOP_FORCE = 5000
	character.AIR_STOP_FORCE = 100
	
	character.JUMP_SPEED = 300
	character.DOUBLE_JUMP_SPEED = 200
	character.JUMP_GATE_SPEED = 75
	character.FALL_GATE_SPEED = 300
	
	character.SLIDE_STOP_VELOCITY = 1.0 # one pixel/second
	character.SLIDE_STOP_MIN_TRAVEL = 1.0 # one pixel

func ground_neutral(character):
	print("ground neutral")

func ground_side(character):
	print("ground side")
	
	var attackObj = SwordArc.instance()
	character.add_child(attackObj)
	if character.left:
		attackObj.start(-10)
	if character.right:
		attackObj.start(10)
	character.attackLagFrame = 0.5
	character.movementLagFrame = 0.5

func ground_up(character):
	print("ground up")
	var attackObj = RisingArc.instance()
	character.add_child(attackObj)
	if character.direction == "left":
		attackObj.start(-15)
	else:
		attackObj.start(15)
	character.attackLagFrame = 0.6
	character.movementLagFrame = 0.3
	
func ground_down(character):
	print("ground down")

func ground_jump(character):
	character.velocity.y = -JUMP_SPEED
	character.jumping = true
	print("ground jump")
	
func air_neutral(character):
	print("air neutral")

func air_side(character):
	print("air side")
	var attackObj = SwordArc.instance()
	character.add_child(attackObj)
	if character.left:
		attackObj.start(-10)
	if character.right:
		attackObj.start(10)
	character.attackLagFrame = 0.5

func air_up(character):
	print("air up")
	var attackObj = RisingArc.instance()
	character.add_child(attackObj)
	if character.direction == "left":
		attackObj.start(-15)
	else:
		attackObj.start(15)
	character.attackLagFrame = 0.6
	character.movementLagFrame = 0.3
	
func air_down(character):
	print("air down")
	
func air_jump(character):
	if character.jump and not character.prev_jump_pressed and not double_jumping:
		character.velocity.y = -DOUBLE_JUMP_SPEED
		double_jumping = true
		if character.left:
			character.velocity.x = -character.WALK_MAX_SPEED
		elif character.right:
			character.velocity.x = character.WALK_MAX_SPEED
		else:
			character.velocity.x = 0
		
func touch_ground(character):
	double_jumping = false