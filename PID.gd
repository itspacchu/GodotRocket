extends Object


class_name PID
	
var kp : float = 0.0
var ki = 0.0
var kd = 0.0
var prev = 0.0
var inte_d = 0.0
	
func _init(p,i,d):
	self.kp = p
	self.ki = i 
	self.kd = d

func _update(err,dt):
	var prop_d = err*self.kp 
	var diff_d = (err - self.prev)/dt
	var inte_d = self.inte_d + err*dt
	self.prev = err
	return self.kp*prop_d + self.ki*inte_d + self.kd*diff_d
	
	
