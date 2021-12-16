extends RigidBody
export (float) var thrustForce:float = 20;
export (float) var sideForce:float = 0.1;
export (float) var speed:float = 0; 
var thrustloc = Vector3(0,-1,0);
var autopilot:bool = true
var landingmode:bool = false

var target_rot = Vector3(0,0,0)
var target_pos = Vector3(0,1,0)
var thrust_vec = Vector3(0.0,0,0.0)

var PID_X = null
var PID_Z = null
var PID_Y = null

var PID_Ypos = null

var PID_tv_x = null
var PID_tv_z = null

func _ready():
	#rotational side thrusters
	PID_X = preload("res://PID.gd").new(1, 0.2, 0.5)
	PID_Z = preload("res://PID.gd").new(1, 0.2, 0.5)
	#thrust vectoring
	PID_tv_x = preload("res://PID.gd").new(0.5, 0.1, 0.1)
	PID_tv_z = preload("res://PID.gd").new(0.5, 0.1, 0.1)
	#height calib
	PID_Ypos = preload("res://PID.gd").new(0.75, 0.35, 0.75)
	PID_tv_x._set_range(-0.3,0.3)
	PID_tv_z._set_range(-0.3,0.3)
	PID_Ypos._set_range(0,1)
	#PID_Ypos.minimum_clamp = 0; # can't get negative thrust right

	
func _process(delta):
	DebugDraw.draw_box(target_pos,Vector3.ONE/2,Color(0,1,1))
	$Booster/OmniLight.light_energy = 5*int($Booster.emitting)
	if(Input.is_key_pressed(KEY_Y)):
		self.apply_torque_impulse(Vector3(rand_range(-3,3),0,rand_range(-3,3)))
	
	var in_v = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	var in_h = Input.get_action_strength("ui_up") - Input.get_action_strength("ui_down")
	
	if(Input.get_action_strength("tg_up")):
		target_pos.y += Input.get_action_strength("tg_up")*thrustForce*delta/4
	if(Input.get_action_strength("tg_down")):
		target_pos.y -= Input.get_action_strength("tg_down")*thrustForce*delta/4
	
	target_pos.x -= in_h*delta*10
	target_pos.z -= in_v*delta*10
	
	if(landingmode || Input.is_key_pressed(KEY_K)):
		if(landingmode==false):
			landingmode = true;
		target_pos.x =  lerp(target_pos.x,0,0.75*delta)
		target_pos.z =  lerp(target_pos.z,0,0.75*delta)
		target_pos.y =  lerp(target_pos.y,0,0.3*delta)
		
func _physics_process(delta):	
	self.speed =  self.linear_velocity.length()
	

	_apply_corr(delta)

func _apply_corr(delta):
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
	
	thrust_vec.x = PID_tv_x._update(-err_pos_x,delta)
	thrust_vec.z = PID_tv_z._update(-err_pos_z,delta)
	
	var pidx = PID_X._update(err_rot_x,delta)
	var pidz = PID_Z._update(err_rot_z,delta)
	
	
	
	
	var pidh = PID_Ypos._update(err_pos_y,delta)
	$RichTextLabel.text = "pidx : " + str(pidx) +"\npidz  : " + str(pidz) +"\ntv.x : " + str(thrust_vec.x) +"\ntv.y  : " + str(thrust_vec.z)
	self.apply_torque_impulse(sideForce*pidx*transform.basis.x*delta)
	self.apply_torque_impulse(sideForce*pidz*transform.basis.z*delta)
	self.add_force(thrustForce*pidh*transform.basis.y,thrustloc + thrust_vec)

	
	animate_thrusters(pidx,pidz)
		
func animate_thrusters(x,z):
	if(x > 0.05):
		$SideZp.emitting = true;
	else:
		$SideZp.emitting = false;
	if(x < -0.05):
		$SideZn.emitting = true;
	else:
		$SideZn.emitting = false;
	if(z > 0.05):
		$SideXp.emitting = true;
	else:
		$SideXp.emitting = false;
	if(z < -0.05):
		$SideXn.emitting = true;
	else:
		$SideXn.emitting = false;		
	if(self.linear_velocity.length() > 0.1  || (self.translation.y > 1.2)):
		print(self.linear_velocity.length())
		$Booster.emitting= true
	else:
		$Booster.emitting= false
	$Booster.translation = thrustloc
	var tv = Vector3(thrust_vec.z,-1,thrust_vec.x)
	$Booster.rotation = tv
	$Booster.lifetime = speed/25
	
	
