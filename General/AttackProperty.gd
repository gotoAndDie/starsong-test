extends Object

class_name AttackProperty

enum df {LINEAR, QUADRATIC}

var origin = null

var damage = 0
var damageParameter = 0
var damageFunction = df.LINEAR


var direction = 0  # Angle at which opponent is launched
var force = 0      # Launch force; something like 200 would be a reasonable median
var stun = 0       # How long 
var flyStun = 0    # How long an opponent hit by the attack should fly
var launch = false # Whether the attack (is supposed to) launch an opponent, or is part of a combo

var delayFrames = 3/60   # The amount of time between the attack hitting and the effects occuring

func init(damage, direction, force, stun, flystun):
	self.damage = damage
	self.direction = direction
	self.force = force
	self.stun = stun
	self.flyStun = flystun
	return self
	
func setOrigin(character):
	origin = character
	
func setDamage(damage):
	self.damage = damage
	return self
func setDamageParam(param):
	self.damageParameter = param
	return self
func damageIsLinear():
	self.damageFunction = df.LINEAR
	return self
func damageIsQuadratic():
	self.damageFunction = df.QUADRATIC
	return self
	
# Computes damage based on the set parameters
func getDamage(targetShine):
	var shineFactor = origin.shine + targetShine / 5
	if damageFunction == df.LINEAR:
		return damage + damageParameter * shineFactor / 100
	elif damageFunction == df.QUADRATIC:
		return damage + damageParameter * pow(shineFactor / 100, 2)
	
func invert():
	direction = -direction
	return self