extends Spatial

export (float) var height = 10;
export (NodePath) var targetNodePath = null
export var done = false;
var percentage = 0;
var Rocket;

var START;
var END;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Rocket = get_node(targetNodePath)
	START = get_node("START")
	END   = get_node("END")

