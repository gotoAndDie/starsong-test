extends Area2D

var remain = 0
var theCollision
var direction
var hitslist = []

func _init():
	connect("body_entered", self, "collision")
	remain = 0.1

func start(disp):
	print("Rising sword generated")
	position = Vector2(disp,-15)
	direction = disp

func _physics_process(delta):
	if remain <= 0:
		position = Vector2(9999,9999)
		get_parent().velocity.y = -200
		self.queue_free()
	else:
		remain = remain - delta
		get_parent().velocity.y = -800
		get_parent().velocity.x = 0
		
func collision(body):
	# origin, type, damage, direction, force, stun, flystun
	if hitslist.find(body) == -1 && body.has_method("hit") && body != get_parent():
		if direction > 0: # right
			body.hit(get_parent(), "sword", 5, -75, 200, 0.1, 0.1)
		else: #left
			body.hit(get_parent(), "sword", 5, 75, 200, 0.1, 0.1)
	hitslist.append(body)