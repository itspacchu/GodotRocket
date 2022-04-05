extends RigidBody
export (float) var thrustForce:float = 20;
export (float) var sideForce:float = 0.5;
export (float) var speed:float = 0; 
var thrustloc = Vector3(0,-1,0);
export var autopilot:bool = true
var landingmode:bool = false
var oldP = true;
export var target_rot = Vector3(0,0,0)
export var target_pos = Vector3(0,1,0)
export var thrust_vec = Vector3(0.0,0,0.0)


var PID_X = null
var PID_Z = null
var PID_Y = null

var PID_Ypos = null

var PID_tv_x = null
var PID_tv_z = null

func _ready():
	#rotational side thrusters
	PID_X = preload("res://scripts/PID.gd").new(2, 0.5, 0.6)
	PID_Z = preload("res://scripts/PID.gd").new(2, 0.5, 0.6)
	#thrust vectoring
	PID_tv_x = preload("res://scripts/PID.gd").new(0.7, 0.5, 0.15)
	PID_tv_z = preload("res://scripts/PID.gd").new(0.7, 0.5, 0.15)
	#height calib
	PID_Ypos = preload("res://scripts/PID.gd").new(1.5, 0.35, 0.85)
	PID_tv_x._set_range(-0.2,0.2)
	PID_tv_z._set_range(-0.2,0.2)
	PID_Ypos._set_range(0,3)


func _process(delta):
	DebugDraw.draw_box(target_pos - Vector3(0.5,0.5,0.5),Vector3.ONE,Color(0,0,0))
	$Booster/OmniLight.light_energy = 5*int($Booster.emitting)
	
	if(Input.is_key_pressed(KEY_Y)):
		self.apply_torque_impulse(Vector3(rand_range(-3,3),0,rand_range(-3,3)))

	var in_h = - Input.get_action_strength("ui_right") + Input.get_action_strength("ui_left")
	var in_v = Input.get_action_strength("ui_up") - Input.get_action_strength("ui_down")
	
	if(Input.get_action_strength("tg_up")):
		target_pos.y += Input.get_action_strength("tg_up")*thrustForce*delta/4
	if(Input.get_action_strength("tg_down") and target_pos.y > 0):
		target_pos.y -= Input.get_action_strength("tg_down")*thrustForce*delta/4
	elif(target_pos.y <= 0):
		target_pos.y = 0.1
	
	
	
	target_pos.x -= in_h*delta*10
	target_pos.z -= in_v*delta*10

		
func _physics_process(delta):	
	self.speed =  self.linear_velocity.length()
	_apply_corr(delta)
		
func _apply_corr(delta):
	var rx = self.rotation.x
	var rz = self.rotation.z
	
	var px = self.translation.x
	var pz = self.translation.z
	var height = self.translation.y
	
	var err_rot_x:float = 0;
	var err_rot_z:float = 0; #vec2 y = z
	
	var err_pos_x:float = 0;
	var err_pos_z:float = 0;
	var err_pos_y:float = 0;
	
	if(autopilot):
		err_rot_x = target_rot.x - rx;
		err_rot_z = target_rot.z - rz; #vec2 y = z
	
		err_pos_x = target_pos.x - px;
		err_pos_z = target_pos.z - pz;
		err_pos_y = target_pos.y - height;	
	
	thrust_vec.x = PID_tv_x._update(-err_pos_x,delta/3)
	thrust_vec.z = PID_tv_z._update(-err_pos_z,delta/3)

	var pidx = PID_X._update(err_rot_x,delta/3)
	var pidz = PID_Z._update(err_rot_z,delta/3)
	var pidh = PID_Ypos._update(err_pos_y,delta/3)
	
	if(autopilot):
		self.apply_torque_impulse(sideForce*pidx*transform.basis.x*delta)
		self.apply_torque_impulse(sideForce*pidz*transform.basis.z*delta)
		self.add_force(thrustForce*pidh*transform.basis.y,thrustloc + thrust_vec)
	else:
		var diffx = self.translation.x - self.target_pos.x
		var diffz = self.translation.z - self.target_pos.z
		var diffh = self.target_pos.y - self.translation.y
		
		self.apply_torque_impulse(-sideForce*diffx*transform.basis.x*delta*0.1)
		self.apply_torque_impulse(-sideForce*diffh*transform.basis.z*delta*0.1)
		self.add_force(thrustForce*diffh*transform.basis.y,thrustloc + thrust_vec)
		
		DebugDraw.draw_ray_3d($Booster.translation,thrust_vec,100,Color(1,0.75,0.4));
	if(autopilot):
		animate_thrusters(pidx,pidz)
	
	$STATsplay/D.value = PID_X.diff_d
	$STATsplay/D2.value = PID_Z.diff_d
	$STATsplay/I.value = PID_X.inte_d
	$STATsplay/I2.value = PID_Z.inte_d
	$STATsplay/P.value = PID_X.prop_d
	$STATsplay/P2.value = PID_Z.prop_d
	
	$STATsplay/H.value = PID_Ypos.prop_d
	$STATsplay/H2.value = PID_Ypos.inte_d
	$STATsplay/H3.value = PID_Ypos.diff_d
	
		
func animate_thrusters(x,z,enabled=true):
	if(enabled):
		if(x > 0.05):
			$SideZp.emitting = true;
		else:
			$SideZp.emitting = false;
		if(x < -0.05):
			$SideZn.emitting = true;
		else:
			$SideZn.emitting = false;
		if(z > 0.05):
			$SideXn.emitting = true;
		else:
			$SideXn.emitting = false;
		if(z < -0.05):
			$SideXp.emitting = true;
		else:
			$SideXp.emitting = false;		
		if(self.linear_velocity.length() > 0.1  || (self.translation.y > 1.2)):
			$Booster.emitting= true
		else:
			$Booster.emitting= false
		$Booster.translation = thrustloc
		var tv = Vector3(-thrust_vec.z,-1,-thrust_vec.x)
		$Booster.rotation = tv
		$Booster.lifetime = speed/25
	else:
		$SideZp.emitting = false
		$SideXn.emitting = false
		$SideXp.emitting = false
		$SideZn.emitting = false
		$Booster.emitting = false
