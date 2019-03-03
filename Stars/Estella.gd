const WALK_FORCE = 600
const WALK_MIN_SPEED = 10
const WALK_MAX_SPEED = 200
const STOP_FORCE = 2600
const JUMP_SPEED = 300
const DOUBLE_JUMP_SPEED = 200
const JUMP_GATE_SPEED = 75
const JUMP_MAX_AIRBORNE_TIME = 0.2

var double_jumping = false

var SwordArc

func starInit(character):
	print("Estella")
	SwordArc = load("res://Moves/SwordArc.tscn")

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
	character.attacking = 0.5
	character.justAttacked = 0.5

func ground_up(character):
	print("ground up")
	
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
	character.attacking = 0.5

func air_up(character):
	print("air up")
	
func air_down(character):
	print("air down")
	
func air_jump(character):
	if character.jump and not character.prev_jump_pressed and not double_jumping:
		character.velocity.y = -DOUBLE_JUMP_SPEED
		double_jumping = true
		if character.left:
			character.velocity.x = -WALK_MAX_SPEED
		elif character.right:
			character.velocity.x = WALK_MAX_SPEED
		
func touch_ground(character):
	double_jumping = false