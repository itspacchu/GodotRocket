extends RichTextLabel

var rocket;
var autopiloten = false;

func _ready():
	rocket = get_parent().get_node("mainRocket")
	


func _process(delta):
	autopiloten = rocket.get("autopilot")
	self.text = "height : " + str(round(rocket.translation.y)) + " m :: PID : " + str(autopiloten)
	
	
