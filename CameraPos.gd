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
	springArmNode.spring_length = lerp(springArmNode.spring_length, remap(targetNode.get("speed"),0,50,5,50),delta*10)
	
	if(Input.is_key_pressed(KEY_A)):
		self.rotation.y = lerp(self.rotation.y,self.rotation.y - delta,0.5)
	elif(Input.is_key_pressed(KEY_D)):
		self.rotation.y = lerp(self.rotation.y,self.rotation.y + delta,0.5)
