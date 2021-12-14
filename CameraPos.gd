extends Position3D

export (NodePath) var targetNodePath = null
var targetNode
var camera;
var springArmNode
export (float) var lerpSpeed = 0.05

func remap(val,inlow,inhigh,outlow,outhigh):
	return (val - inlow) / (inhigh - inlow) * (outhigh - outlow) + outlow

func _ready():
	targetNode = get_node(targetNodePath)
	camera = get_node("SpringArm/Camera")
	springArmNode = get_node("SpringArm")
	print(targetNode.get("speed"))
	
func _physics_process(delta):
	self.translation = lerp(self.translation,targetNode.translation,lerpSpeed*delta)
	
	#camera.fov = remap(targetNode.get("speed"),0,50,70,150)
	springArmNode.spring_length = lerp(springArmNode.spring_length, remap(targetNode.get("speed"),0,50,2,10),delta*10)
