extends "GenericPlayer.gd"

var star
	
func getInput():
	left = Input.is_action_pressed("move_left_2")
	right = Input.is_action_pressed("move_right_2")
	jump = Input.is_action_pressed("jump_2")
	fire = Input.is_action_pressed("fire_2")
	special = Input.is_action_pressed("special_2")
	up = Input.is_action_pressed("move_up_2")
	down = Input.is_action_pressed("move_down_2")
	
func starInit():
	star = load("res://Stars/" + Globals.star_p2 + ".gd").new()
	star.starInit(self)

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