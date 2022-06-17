extends Control

var rocketObjectNode = null
var textObjectNode = null

func _ready() -> void:
	rocketObjectNode = get_parent().get_node("RigidBody")
	textObjectNode = get_node("RocketRollYawPitch")

func _process(delta: float) -> void:
	var targetPos = rocketObjectNode.target_pos
	var currentPos = rocketObjectNode.translation
	textObjectNode.text = " Target: %s \nCurrent: %s"%[targetPos,currentPos]
	rocketObjectNode.autopilot = $CheckButton.pressed
