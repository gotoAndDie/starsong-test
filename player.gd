extends "GenericPlayer.gd"

var star
	
func getInput():
	left = Input.is_action_pressed("move_left")
	right = Input.is_action_pressed("move_right")
	jump = Input.is_action_pressed("jump")
	fire = Input.is_action_pressed("fire")
	special = Input.is_action_pressed("special")
	up = Input.is_action_pressed("move_up")
	down = Input.is_action_pressed("move_down")
	
	var debugNode = get_node("DEBUG")
	
	var joy_lx = Input.get_joy_axis(0, JOY_ANALOG_LX)
	var joy_ly = Input.get_joy_axis(0, JOY_ANALOG_LY)
	var joy_rx = Input.get_joy_axis(0, JOY_ANALOG_RX)
	var joy_ry = Input.get_joy_axis(0, JOY_ANALOG_RY)
	
	# Force x value to not be zero to avoid division by zero
	if joy_lx == 0:
		joy_lx = 0.00001
	if joy_rx == 0:
		joy_rx = 0.00001
		
	# Translate joystick values into digital directions
	right = right || (joy_lx > Globals.DEADZONE)
	left = left || (joy_lx < -Globals.DEADZONE)
	
	# Write joystick values to debug text display
	debugNode.clear()
	debugNode.add_text("Joy LX: " + str(joy_lx) + "\n")
	debugNode.add_text("Joy LY: " + str(joy_ly) + "\n")
	debugNode.add_text("Joy LA: " + str(atan(joy_ly/joy_lx)) + "\n")
	#debugNode.add_text("Joy RX: " + str(joy_rx) + "\n")
	#debugNode.add_text("Joy RY: " + str(joy_ry) + "\n")
	#debugNode.add_text("Joy Lθ: " + str(atan(joy_ry/joy_rx)) + "\n")
	
	var collision = get_slide_collision(0)
	var angle
	if collision == null:
		angle = 100
	else: 
		angle = get_slide_collision(0).get_normal().angle() + 0.5 * PI
	debugNode.add_text("Self angle: " + str(rotation) + "\n")
	
	
	var derot_velocity = velocity.rotated(-rotation)
	debugNode.add_text("Derot_v: " + str(derot_velocity.x) + ", " + str(derot_velocity.y))
	
	# Translate joystick x to absolute value
	x_factor = abs(joy_lx)
	
	# Obtain angle of joystick
	theta = atan(joy_ly/joy_lx)

func starInit():
	star = load("res://Stars/" + Globals.star_p1 + ".gd").new()
	star.starInit(self)
	# self.rotation = 20

func ground_neutral():
	star.ground_neutral(self)
func ground_side():
	star.ground_side(self)
func ground_up():
	star.ground_up(self)
func ground_down():
	star.ground_down(self)
func ground_jump():
	star.ground_jump(self)
	
func air_neutral():
	star.air_neutral(self)
func air_side():
	star.air_side(self)
func air_up():
	star.air_up(self)
func air_down():
	star.air_down(self)
func air_jump():
	star.air_jump(self)
	
	
func touch_ground():
	star.touch_ground(self)