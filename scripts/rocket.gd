extends RigidBody
export (float) var thrustForce:float = 20;
export (float) var sideForce:float = 10;
export (float) var speed:float = 0; 

var thrustloc = Vector3(0,-1,0);
export var autopilot:bool = true
var landingmode:bool = false
var oldP = true;

export var target_rot = Vector3(0,0,0)
export var target_pos = Vector3(0,1,0)
export var thrust_vec = Vector3(0.0,0,0.0)

var tgupdown:float = 0;

var PID_X = null
var PID_Z = null
var PID_Y = null

var PID_Ypos = null

var PID_tv_x = null
var PID_tv_z = null

func _ready():
	#rotational side thrusters
	PID_X = preload("res://scripts/PID.gd").new(1, 0.9, 0.6)
	PID_Z = preload("res://scripts/PID.gd").new(1, 0.9, 0.6)
	#thrust vectoring
	PID_tv_x = preload("res://scripts/PID.gd").new(0.75, 0.5, 0.25)
	PID_tv_z = preload("res://scripts/PID.gd").new(0.75, 0.5, 0.25)
	#height calib
	PID_Ypos = preload("res://scripts/PID.gd").new(1.0, 0.1, 0.85)
	PID_tv_x._set_range(-0.4,0.4)
	PID_tv_z._set_range(-0.4,0.4)
	PID_Ypos._set_range(0,3)


func _process(delta):
	DebugDraw.draw_box(target_pos - Vector3(0.5,0.5,0.5),Vector3.ONE,Color(0.5,0.5,0.5))
	$Booster/OmniLight.light_energy = 5*int($Booster.emitting)
	
	if(Input.is_key_pressed(KEY_Y)):
		self.apply_torque_impulse(Vector3(rand_range(-3,3),0,rand_range(-3,3)))
	
	
	self.apply_torque_impulse(0.01*sideForce*transform.basis.y*delta)
	var in_h = - Input.get_action_strength("ui_right") + Input.get_action_strength("ui_left")
	var in_v = Input.get_action_strength("ui_up") - Input.get_action_strength("ui_down")
	var inUpact = Input.get_action_strength("tg_up")
	var inDownact = Input.get_action_strength("tg_down")
	
	if(Input.get_action_strength("tg_up")):
		target_pos.y += lerp(inUpact,1,delta*0.01)*(thrustForce)*delta/10;
	if(Input.get_action_strength("tg_down") and target_pos.y > 0):
		target_pos.y -= lerp(inDownact,0,delta*0.1)*(thrustForce)*delta/10;
	if(target_pos.y <= 0):
		target_pos.y = 0.1
	
	
	
	target_pos.x -= in_h*delta*5
	target_pos.z -= in_v*delta*5

		
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

		
	animate_thrusters(pidx,pidz,pidh,autopilot)
	
	#DebugDraw.draw_line_3d(self.translation,self.translation+ 2*thrust_vec,Color(1,0.75,0.4));
	
	$STATsplay/Control/D.value = PID_X.diff_d
	$STATsplay/Control/D/D2.value = PID_Z.diff_d
	$STATsplay/Control/I.value = PID_X.inte_d
	$STATsplay/Control/I/I2.value = PID_Z.inte_d
	$STATsplay/Control/P.value = PID_X.prop_d
	$STATsplay/Control/P/P2.value = PID_Z.prop_d
	
	$STATsplay/Control/H.value = PID_Ypos.prop_d
	$STATsplay/Control/H/H2.value = PID_Ypos.inte_d
	$STATsplay/Control/H/H3.value = PID_Ypos.diff_d

		
func animate_thrusters(x,z,y,enabled=true):
	if(enabled):
		$DroneRootRocket/lower/bldc/BLDC/fan/mainfan/MotionTrail3.trailEnabled = true
		$DroneRootRocket/Movables/vane_4x.set_rotation_degrees(Vector3(0,0,atan(-z)*40))
		$DroneRootRocket/Movables/vane_4x2.set_rotation_degrees(Vector3(0,90,atan(-x)*40))
		$DroneRootRocket/Movables/vane_4x3.set_rotation_degrees(Vector3(0,180,atan(z)*40))
		$DroneRootRocket/Movables/vane_4x4.set_rotation_degrees(Vector3(0,270,atan(x)*40))
		$DroneRootRocket/lower/bldc/BLDC/fan/mainfan.rotate_object_local(Vector3(0,0,1),atan(self.translation.y - 0.6)*15)
	else:
		$DroneRootRocket/lower/bldc/BLDC/fan/mainfan/MotionTrail3.trailEnabled = false
