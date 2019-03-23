extends Area2D

var remain = 0
var theCollision
var direction
var hitslist = []
var attackProperty

func _init():
	connect("body_entered", self, "collision")

func start(dispx, dispy, attackProperty : AttackProperty, duration):
	print("Sword generated")
	self.direction = dispx
	self.attackProperty = attackProperty
	position = Vector2(dispx,dispy)
	remain = duration

func _physics_process(delta):
	if remain <= 0:
		position = Vector2(9999,9999)
		self.queue_free()
	else:
		remain = remain - delta
	#theCollision = move_and_collide(Vector2(0,0))
	#if theCollision != null:
	#	collision(theCollision.get_collider())
		
func collision(body):
	# origin, type, damage, direction, force, stun, flystun
	if hitslist.find(body) == -1 && body.has_method("hit") && body != get_parent():
		if direction > 0: # right
			body.hit(get_parent(), "sword", attackProperty)
		else: #left
			body.hit(get_parent(), "sword", attackProperty.invert())
	hitslist.append(body)