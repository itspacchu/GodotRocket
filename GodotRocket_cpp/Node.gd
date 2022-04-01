extends Node


func _ready() -> void:
	var test = load("res://Main.gdns").new()
	print(test.callbooba())

