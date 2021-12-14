extends RigidBody

export (float) var thrustForce:float = 20;
export (float) var sideForce:float = 5;
export (float) var speed:float = 0; 
var thrustloc = Vector3(0,-1,0);
var autopilot:bool = false

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
		_apply_corr_torque()

func _apply_corr_torque():
	var rx = self.rotation.x
	var rz = self.rotation.z
	#sorcery P controller
	if(rx > 0.1 && rx < 1):
		self.add_torque(-sideForce*abs(rx)*transform.basis.x)
		$SideZp.emitting = true;
	if(rx < -0.1 && rx > -1):
		self.add_torque(sideForce*abs(rx)*transform.basis.x)
		$SideZn.emitting = true;
		
	if(rz > 0.1 && rz < 1):
		self.add_torque(-sideForce*abs(rz)*transform.basis.z)
		$SideXp.emitting = true;
	if(rz < -0.1 && rz > -1):
		self.add_torque(sideForce*abs(rx)*transform.basis.z)
		$SideXn.emitting = true;
		
	if(not(Input.is_key_pressed(KEY_SPACE)) && self.linear_velocity.y < -0.1):
		self.add_force((speed/10)*thrustForce*transform.basis.y.normalized(),Vector3.ZERO)
		$Booster.emitting= true
		
		
		
		
	
	
