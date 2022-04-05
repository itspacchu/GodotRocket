extends Spatial

export (NodePath) var targetNodePath = null

var targetNode
var camera;
var springArmNode
export (float) var lerpSpeed = 0.05
var xangle = 0;
var yangle = 0;
var pitch = 0;

func remap(val,inlow,inhigh,outlow,outhigh):
	return (val - inlow) / (inhigh - inlow) * (outhigh - outlow) + outlow

func _ready():
	targetNode = get_node(targetNodePath)
	camera = get_node("SpringArm/Camera")
	springArmNode = get_node("SpringArm")
	OS.window_fullscreen = true;

func _physics_process(delta):
	self.translation = lerp(self.translation,targetNode.translation,lerpSpeed*delta)
	springArmNode.spring_length = lerp(springArmNode.spring_length, remap(targetNode.get("speed"),0,50,2,30),delta*10)
	self.rotation.x = lerp(self.rotation.x,remap(targetNode.get("speed"),0,50,-PI/5,PI/2),delta*0.3)
	
#	self.rotate_y(remap(targetNode.get("speed"),0,50,0.5,1) * delta*(-Input.get_action_strength("cam_yp") + Input.get_action_strength("cam_yn")))
#	self.rotate_z(remap(targetNode.get("speed"),0,50,0.5,1) * delta*(-Input.get_action_strength("cam_xp") + Input.get_action_strength("cam_xn")))
#	var dir = (targetNode.target_pos - self.translation)
#	dir.z = self.translation.z;
	
	yangle = lerp(yangle,-Input.get_action_strength("cam_xp") + Input.get_action_strength("cam_xn"),delta*0.7)
	xangle = lerp(xangle,-Input.get_action_strength("cam_yp") + Input.get_action_strength("cam_yn"),delta*0.7)
	pitch = lerp(pitch,-Input.get_action_strength("cam_p") + Input.get_action_strength("cam_n"),delta*0.7)

	self.rotate_y(remap(targetNode.get("speed"),0,50,0.5,1) * delta*(yangle))
	self.rotate_z(remap(targetNode.get("speed"),0,50,0.5,1) * delta* (xangle))
	self.rotate_x(remap(targetNode.get("speed"),0,50,0.5,1) * delta* (pitch))
	var dir = (targetNode.target_pos - self.translation)
	dir.z = self.translation.z;
