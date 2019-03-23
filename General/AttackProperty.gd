extends Object

class_name AttackProperty

var damage = 0
var direction = 0
var force = 0
var stun = 0
var flyStun = 0

func init(damage, direction, force, stun, flystun):
	self.damage = damage
	self.direction = direction
	self.force = force
	self.stun = stun
	self.flyStun = flystun
	return self
	
func invert():
	direction = -direction
	return self