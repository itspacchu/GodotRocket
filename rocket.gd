extends RigidBody
export (float) var thrustForce:float = 20;
export (float) var sideForce:float = 4;
export (float) var speed:float = 0; 
var thrustloc = Vector3(0,-1,0);
var autopilot:bool = true

var target_rot = Vector3(0,0,0)
var target_pos = Vector3(0,10,0)

var PID_X = null
var PID_Z = null
var PID_Y = null

var PID_Xpos = null
var PID_Zpos = null
var PID_Ypos = null

var PID_tv_x = null
var PID_tv_z = null

func _ready():
	#rotational side thrusters
	PID_X = preload("res://PID.gd").new(1, 0.2, 0.5)
	PID_Z = preload("res://PID.gd").new(1, 0.2, 0.5)
	#positional
	PID_Xpos = preload("res://PID.gd").new(1, 0.5, -0.1)
	PID_Zpos = preload("res://PID.gd").new(1, 0.5, -0.1)
	PID_Ypos = preload("res://PID.gd").new(1, 0.5, 0.5)
	
	PID_Ypos.minimum_clamp = 0; # can't get negative thrust right
	
	PID_Xpos._set_range(-0.5,0.5)
	PID_Zpos._set_range(-0.5,0.5)
	
func _process(delta):
	$Booster/OmniLight.light_energy = 5*int($Booster.emitting)

func _physics_process(delta):
	$Booster.translation = thrustloc
	if(Input.is_key_pressed(KEY_SPACE)):
		self.add_force(thrustForce*transform.basis.y.normalized(),thrustloc)
		$Booster.emitting= true
	else:
		$Booster.emitting= false
	
	var in_h = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	var in_v = Input.get_action_strength("ui_up") - Input.get_action_strength("ui_down")
	if(Input.is_key_pressed(KEY_Q)):
		target_pos.y += delta*10
	if(Input.is_key_pressed(KEY_E)):
		target_pos.y -= delta*10
			
	target_pos.x -= in_h*delta
	target_pos.z += in_v*delta
	print(target_pos)

	self.speed =  self.linear_velocity.length()
	

	_apply_corr_torque(delta)

func _apply_corr_torque(delta):
	var rx = self.rotation.x
	var rz = self.rotation.z
	
	var px = self.translation.x
	var pz = self.translation.z
	var height = self.translation.y
	
	var err_rot_x:float = target_rot.x - rx;
	var err_rot_z:float = target_rot.z - rz; #vec2 y = z
	
	var err_pos_x:float = target_pos.x - px;
	var err_pos_z:float = target_pos.z - pz;
	var err_pos_y:float = target_pos.y - height;
	
	#target_rot.x = PID_Xpos._update(err_pos_x,delta)
	#target_rot.z = PID_Zpos._update(err_pos_z,delta)
	
	
	var pidx = PID_X._update(err_rot_x,delta)
	var pidz = PID_Z._update(err_rot_z,delta)
	
	var pidh = PID_Ypos._update(err_pos_y,delta)
	$RichTextLabel.text = "pidx : " + str(pidx) +"\npidz  : " + str(pidz)
	self.add_torque(sideForce*pidx*transform.basis.x)
	self.add_torque(sideForce*pidz*transform.basis.z)
	self.add_force(thrustForce*pidh*transform.basis.y,Vector3.ZERO)
	
	animate_thrusters(pidx,pidz)
		
func animate_thrusters(x,z):
	if(x > 0.1):
		$SideZp.emitting = true;
	if(x < -0.1):
		$SideZn.emitting = true;
	if(z > 0.1):
		$SideXp.emitting = true;
	if(z < -0.1):
		$SideXn.emitting = true;
	if(self.linear_velocity):
		$Booster.emitting= true
	
