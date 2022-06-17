extends Node

var RocketObj = null
var StartingPos = null
var EndingPos = null
onready var start_time = OS.get_ticks_msec()
var height = 100

var Midway = null
var TOT_POINTS = 10.0

var MAX_DIST = 0
var FINISHED = 0

var points = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	RocketObj = $RigidBody
	StartingPos = $LandingSystem/START
	EndingPos = $LandingSystem/END
	RocketObj.target_pos = StartingPos.translation
	Midway = (StartingPos.translation + EndingPos.translation)/2
	MAX_DIST = RocketObj.target_pos.distance_to(Midway)
	points = generate_points_to_end()

func generate_points_to_end():
	var ps = []
	var interp = StartingPos.translation
	ps.append(interp)
	for i in range(1,TOT_POINTS):
		interp = ((TOT_POINTS-i)*StartingPos.translation + (i)*EndingPos.translation)/TOT_POINTS
		interp.y += height*pow(sin(PI*i/TOT_POINTS),0.5)
		ps.append(interp)
	ps.append(EndingPos.translation)
	return ps
	

func launch(delta):
	RocketObj.target_pos = lerp(RocketObj.target_pos,Midway,delta*0.05)
	var dist = Vector3(RocketObj.target_pos.x,0,RocketObj.target_pos.z).distance_to(Midway)
	RocketObj.target_pos.y += 10*sin(2*PI*(delta*0.05))
	return (dist/MAX_DIST < 0.1)
	
func angleBetween(pointA,pointB):
	#var angle = (Vector3(pointB)-Vector3(pointA)).angle()
	#print(angle)
	return Vector3(0,0,0)
	
func _process(delta):
	if(FINISHED <= TOT_POINTS):
		var points = generate_points_to_end()
		RocketObj.target_pos = lerp(RocketObj.target_pos,points[FINISHED],delta)
		RocketObj.target_rot = angleBetween(points[FINISHED-1],points[FINISHED])
		if(RocketObj.translation.distance_to(points[FINISHED]) <= 2):
			FINISHED+=1
	for i in range(1,len(points)):
		DebugDraw.draw_line_3d(points[i-1],points[i],Color((TOT_POINTS-i)/TOT_POINTS,i/TOT_POINTS,0))
		DebugDraw.draw_box(points[i],Vector3.ONE,Color(1,1,1))
	
	



