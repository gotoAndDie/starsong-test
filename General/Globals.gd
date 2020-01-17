extends Node

var star_p1 = "Estella"
var star_p2 = "Estella"

var DEADZONE = 0.1

# Angle constants
var TOP = 0
var TOPRIGHT = -PI / 4
var RIGHT = -PI / 2
var BOTTOMRIGHT = -3 * PI / 4
var BOTTOM = PI
var BOTTOMLEFT = 3 * PI / 4
var LEFT = PI / 2
var TOPLEFT = PI / 4

static func angle_to_angle(from, to):
	var diff = from - to
	return abs(diff) if abs(diff) < PI else abs(diff + (2 * PI * -sign(diff)))