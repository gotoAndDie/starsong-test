extends "GenericPlayer.gd"

var star
var manualControl = 0
var target = self # Default to chasing self
var move_towards = true
var prev_switch_pressed = false
	
func getInput():
	left = Input.is_action_pressed("move_left")
	right = Input.is_action_pressed("move_right")
	jump = Input.is_action_pressed("jump")
	attack = Input.is_action_pressed("fire")
	special = Input.is_action_pressed("special")
	up = Input.is_action_pressed("move_up")
	down = Input.is_action_pressed("move_down")
	
	switch = Input.is_action_pressed("switch")
	
	var debugNode = get_node("DEBUG")
	
	var joy_lx = Input.get_joy_axis(0, JOY_ANALOG_LX)
	var joy_ly = Input.get_joy_axis(0, JOY_ANALOG_LY)
	var joy_rx = Input.get_joy_axis(0, JOY_ANALOG_RX)
	var joy_ry = Input.get_joy_axis(0, JOY_ANALOG_RY)
	
	# Force values to not be zero to avoid division by zero
	if joy_lx == 0:
		joy_lx = 0.00001
	if joy_rx == 0:
		joy_rx = 0.00001
	if joy_ly == 0:
		joy_ly = 0.00001
	if joy_ry == 0:
		joy_ry = 0.00001
		
	if manualControl:
		# Translate joystick values into digital directions
		right = right || (joy_lx > Globals.DEADZONE)
		left = left || (joy_lx < -Globals.DEADZONE)
		# Translate joystick x to absolute value
		x_factor = abs(joy_lx)
	else: # Automatic control
		x_factor = 1;
		if move_towards:
			if target.get_global_position().x > self.get_global_position().x:
				right = true
				left = false
			else:
				right = false
				left = true
			get_node("../GUI").set_player_one_movement("pursue")
		else: 
			if target.get_global_position().x > self.get_global_position().x:
				right = false
				left = true
			else:
				right = true
				left = false
			get_node("../GUI").set_player_one_movement("retreat")
				
		if !prev_switch_pressed && switch:
			prev_switch_pressed = true
			move_towards = !move_towards
		elif !switch:
			prev_switch_pressed = false
	
	
	# Obtain angle of joystick
	if joy_ly < 0:
		joy_l_theta = atan(joy_lx/joy_ly)
	elif joy_lx > 0:
		joy_l_theta = atan(joy_lx/joy_ly) - PI
	else:
		joy_l_theta = atan(joy_lx/joy_ly) + PI
		
	# Obtain magnitude of joystick movement
	joy_l_magnitude = sqrt(joy_lx * joy_lx + joy_ly * joy_ly)
	
	
	# Write joystick values to debug text display
	debugNode.clear()
	debugNode.add_text("Joy LX: " + str(joy_lx) + "\n")
	debugNode.add_text("Joy LY: " + str(joy_ly) + "\n")
	debugNode.add_text("Joy LA: " + str(joy_l_theta) + "\n")
	#debugNode.add_text("Joy RX: " + str(joy_rx) + "\n")
	#debugNode.add_text("Joy RY: " + str(joy_ry) + "\n")
	#debugNode.add_text("Joy Lθ: " + str(atan(joy_ry/joy_rx)) + "\n")
		
	var angle
	if get_slide_count() > 0:
		angle = get_slide_collision(0).get_normal().angle() + 0.5 * PI
	else: 
		angle = 100
	debugNode.add_text("Self angle: " + str(rotation) + "\n")
	
	
	var derot_velocity = velocity.rotated(-rotation)
	debugNode.add_text("Derot_v: " + str(derot_velocity.x) + ", " + str(derot_velocity.y))
	

func starInit():
	star = load("res://Stars/" + Globals.star_p1 + ".gd").new()
	star.starInit(self)

func ground_normal():
	star.ground_normal(self)
func ground_special():
	star.ground_special(self)
func ground_jump():
	star.ground_jump(self)
	
func air_normal():
	star.air_normal(self)
func air_special():
	star.air_special(self)
func air_jump():
	star.air_jump(self)
	
	
func touch_ground():
	star.touch_ground(self)
	
func loop_inject(delta):
	star.loop_inject(self, delta)