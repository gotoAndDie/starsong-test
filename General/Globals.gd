extends Node

var star_p1 = "Estella"
var star_p2 = "Estella"

var DEADZONE = 0.1

static func angle_to_angle(from, to):
	var diff = from - to
	return abs(diff) if abs(diff) < PI else abs(diff + (2 * PI * -sign(diff)))