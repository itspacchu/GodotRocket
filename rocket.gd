extends RigidBody
export (float) var thrustForce:float = 20;
export (float) var sideForce:float = 5;
export (float) var speed:float = 0; 
var thrustloc = Vector3(0,-1,0);
var autopilot:bool = false

var target_x_rot = 0
var target_z_rot = 0
var target_x_pos = 0
var target_z_pos = 0
var target_height = 0

var PID_X = null
var PID_Z = null

func _ready():
	PID_X = preload("res://PID.gd").new(1, 0.5, 0.1)
	PID_Z = preload("res://PID.gd").new(1, 0.5, 0.1)
	

func _physics_process(delta):
	$Booster.translation = thrustloc
	if(Input.is_key_pressed(KEY_SPACE)):
		self.add_force(thrustForce*transform.basis.y.normalized(),Vector3.ZERO)
		#self.add_central_force(thrustForce*transform.basis.y.normalized())
		$Booster.emitting= true
	else:
		$Booster.emitting= false
	
	if(Input.is_key_pressed(KEY_D)):
		self.add_torque(sideForce*transform.basis.x)
		$SideZn.emitting = true;
	else:
		$SideZn.emitting = false;
	
	if(Input.is_key_pressed(KEY_A)):
		self.add_torque(-sideForce*transform.basis.x)
		$SideZp.emitting = true;
	else:
		$SideZp.emitting = false;
		
	if(Input.is_key_pressed(KEY_W)):
		self.add_torque(sideForce*transform.basis.z)
		$SideXp.emitting = true;
	else:
		$SideXp.emitting = false;
		
	if(Input.is_key_pressed(KEY_S)):
		self.add_torque(-sideForce*transform.basis.z)
		$SideXn.emitting = true;
	else:
		$SideXn.emitting = false;
	self.speed =  self.linear_velocity.length()
	
	if(Input.is_key_pressed(KEY_U)):
		autopilot = true
	else:
		autopilot = false
	
	if(autopilot):
		_apply_corr_torque(delta)

func _apply_corr_torque(delta):
	var rx = self.rotation.x
	var rz = self.rotation.z
	
	var proportional_error_x = target_x_rot - rx;
	var proportional_error_y = target_z_rot - rz;
	var pidx = PID_X._update(proportional_error_x,delta)
	var pidz = PID_Z._update(proportional_error_y,delta)
	
	self.add_torque(sideForce*pidx*transform.basis.x)
	self.add_torque(sideForce*pidz*transform.basis.z)
	
	if(pidx > 0.1):
		$SideZp.emitting = true;
		
	if(pidx < -0.1):
		$SideZn.emitting = true;
		
	if(pidz > 0.1):
		$SideXp.emitting = true;
	if(pidz < -0.1):
		$SideXn.emitting = true;
		
	if(not(Input.is_key_pressed(KEY_SPACE)) && self.linear_velocity.y < -0.1):
		self.add_force((speed/10)*thrustForce*transform.basis.y.normalized(),Vector3.ZERO)
		$Booster.emitting= true
