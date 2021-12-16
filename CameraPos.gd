extends Position3D

export (NodePath) var targetNodePath = null
var targetNode
var camera;
var springArmNode
export (float) var lerpSpeed = 0.05
var xangle = 0;
var yangle = 0;
func remap(val,inlow,inhigh,outlow,outhigh):
	return (val - inlow) / (inhigh - inlow) * (outhigh - outlow) + outlow

func _ready():
	targetNode = get_node(targetNodePath)
	camera = get_node("SpringArm/Camera")
	springArmNode = get_node("SpringArm")
	print(targetNode.get("speed"))
func _physics_process(delta):
	self.translation = lerp(self.translation,targetNode.translation,lerpSpeed*delta)
	springArmNode.spring_length = lerp(springArmNode.spring_length, remap(targetNode.get("speed"),0,50,5,30),delta*10)
	
	self.rotate_object_local(Vector3(1,0,0),delta*( -Input.get_action_strength("cam_xp") + Input.get_action_strength("cam_xn")))
	self.rotate_object_local(Vector3(0,1,0),delta*( -Input.get_action_strength("cam_yp") + Input.get_action_strength("cam_yn")))
