const JUMP_SPEED = 300
const DOUBLE_JUMP_SPEED = 200
var double_jumping = false

var SwordArc
var RisingArc

var normalsLag = 0
var specialsLag = 0

var ground_neutral_normal_combo = 0
var ground_neutral_normal_timeout = 0

func starInit(character):
	print("Estella")
	SwordArc = load("res://Moves/SwordArc.tscn")
	RisingArc = load("res://Moves/RisingArc.tscn")
	character.GRAVITY = 500.0 # pixels/second/second
	# Angle in degrees towards either side that the player can consider "floor"
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
	
func ground_normal(character):
	if normalsLag > 0:
		return
	var theta = character.joy_l_theta
	if character.joy_l_magnitude < Globals.DEADZONE:
		ground_neutral(character)
	elif theta > Globals.BOTTOMRIGHT and theta <= Globals.TOPRIGHT:
		ground_side(character)
	elif theta > Globals.TOPRIGHT and theta <= Globals.TOPLEFT:
		ground_up(character)
	elif theta > Globals.TOPLEFT and theta <= Globals.BOTTOMLEFT:
		ground_side(character)
	else:
		ground_down(character)

func ground_neutral(character):
	print("ground neutral")
	if ground_neutral_normal_combo == 0:
		var attackObj = SwordArc.instance()
		var attackProperty = AttackProperty.new().init(3, 45, 20, 0.1, 0.1)
		character.add_child(attackObj)
		if character.direction == "left":
			attackObj.start(-10, 0, attackProperty, 0.1)
		else: 
			attackObj.start(10, 0, attackProperty, 0.1)
		normalsLag = 0.1
		character.movementLagFrame = 0
		ground_neutral_normal_timeout = 0.5
	elif ground_neutral_normal_combo == 1:
		var attackObj = SwordArc.instance()
		var attackProperty = AttackProperty.new().init(3, 45, 20, 0.1, 0.1)
		character.add_child(attackObj)
		if character.direction == "left":
			attackObj.start(-10, 0, attackProperty, 0.1)
		else: 
			attackObj.start(10, 0, attackProperty, 0.1)
		normalsLag = 0.1
		character.movementLagFrame = 0.1
		ground_neutral_normal_timeout = 0.5
	elif ground_neutral_normal_combo == 2:
		var attackObj = SwordArc.instance()
		var attackProperty = AttackProperty.new().init(3, 45, 100, 0.1, 0.1)
		character.add_child(attackObj)
		if character.direction == "left":
			attackObj.start(-10, 0, attackProperty, 0.1)
		else: 
			attackObj.start(10, 0, attackProperty, 0.1)
		normalsLag = 0.5
		character.movementLagFrame = 0.3
		ground_neutral_normal_timeout = 0.5
	ground_neutral_normal_combo += 1

func ground_side(character):
	print("ground side")
	var attackProperty = AttackProperty.new().init(7, 45, 200, 0.1, 0.1)
	
	var attackObj = SwordArc.instance()
	attackObj.setScale(1.3,1.1)
	character.add_child(attackObj)
	if character.left:
		attackObj.start(-12, 0, attackProperty, 0.3)
	if character.right:
		attackObj.start(12, 0, attackProperty, 0.3)
	normalsLag = 0.5
	character.movementLagFrame = 0.4

func ground_up(character):
	print("ground up")
	
func ground_down(character):
	print("ground down")
	

func ground_special(character):
	if specialsLag > 0:
		return
	var theta = character.joy_l_theta
	if character.joy_l_magnitude < Globals.DEADZONE:
		ground_neutral_special(character)
	elif theta > Globals.BOTTOMRIGHT and theta <= Globals.TOPRIGHT:
		ground_side_special(character)
	elif theta > Globals.TOPRIGHT and theta <= Globals.TOPLEFT:
		ground_up_special(character)
	elif theta > Globals.TOPLEFT and theta <= Globals.BOTTOMLEFT:
		ground_side_special(character)
	else:
		ground_down_special(character)

func ground_neutral_special(character):
	print("ground neutral special")

func ground_side_special(character):
	print("ground side special")
	
func ground_up_special(character):
	print("ground up special")
	var attackObj = RisingArc.instance()
	var attackProperty = AttackProperty.new().init(7, 75, 200, 0.1, 0.1)
	character.add_child(attackObj)
	if character.direction == "left":
		attackObj.start(-15, attackProperty, 0.5)
	else:
		attackObj.start(15, attackProperty, 0.5)
	specialsLag = 0.6
	character.movementLagFrame = 0.3
	character.freeFall = true
	
func ground_down_special(character):
	print("ground down special")
	
func ground_jump(character):
	
	var derot_velocity = character.velocity.rotated(-character.rotation)
	derot_velocity.y -= JUMP_SPEED
	character.velocity = derot_velocity.rotated(character.rotation)
	
	
	character.jumping = true
	character.fast_fall_on = true
	character.on_air_time = character.JUMP_MAX_AIRBORNE_TIME
	print("ground jump")
	
func air_normal(character):
	if normalsLag > 0:
		return
	var theta = character.joy_l_theta
	if character.joy_l_magnitude < Globals.DEADZONE:
		air_neutral(character)
	elif theta > Globals.BOTTOMRIGHT and theta <= Globals.TOPRIGHT:
		air_side(character)
	elif theta > Globals.TOPRIGHT and theta <= Globals.TOPLEFT:
		air_up(character)
	elif theta > Globals.TOPLEFT and theta <= Globals.BOTTOMLEFT:
		air_side(character)
	else:
		air_down(character)
		
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
	normalsLag = 0.5

func air_up(character):
	print("air up")
	
func air_down(character):
	print("air down")
	

func air_special(character):
	if specialsLag > 0:
		return
	var theta = character.joy_l_theta
	if character.joy_l_magnitude < Globals.DEADZONE:
		air_neutral_special(character)
	elif theta > Globals.BOTTOMRIGHT and theta <= Globals.TOPRIGHT:
		air_side_special(character)
	elif theta > Globals.TOPRIGHT and theta <= Globals.TOPLEFT:
		air_up_special(character)
	elif theta > Globals.TOPLEFT and theta <= Globals.BOTTOMLEFT:
		air_side_special(character)
	else:
		air_down_special(character)

func air_neutral_special(character):
	print("air neutral special")

func air_side_special(character):
	print("air side special")
	
func air_up_special(character):
	print("air up special")
	var attackObj = RisingArc.instance()
	var attackProperty = AttackProperty.new().init(7, 75, 200, 0.1, 0.1)
	character.add_child(attackObj)
	if character.direction == "left":
		attackObj.start(-15, attackProperty, 0.5)
	else:
		attackObj.start(15, attackProperty, 0.5)
	specialsLag = 0.6
	character.movementLagFrame = 0.3
	character.freeFall = true
	
func air_down_special(character):
	print("air down special")
	
	
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
	print("touch ground")
	double_jumping = false
	
func loop_inject(character, delta):
	if normalsLag > 0:
		normalsLag -= delta
	if specialsLag > 0:
		specialsLag -= delta
	if ground_neutral_normal_timeout > 0:
		ground_neutral_normal_timeout -= delta
	else:
		ground_neutral_normal_combo = 0