extends Node

@onready var matchstick_scene: PackedScene = preload("res://assets/matchstick.tscn")

@export var min_matches: int = 20
@export var max_matches: int = 35
var current_match_count: int

signal match_count_changed(new_match_count: int)
@onready var game_state_chart: StateChart = $"../GameStateChart"

func _on_init_state_entered():
	print("init state entered")
	current_match_count = randi_range(min_matches, max_matches)
	match_count_changed.emit(current_match_count)
	
	for i in range(current_match_count):
		var matchstick: RigidBody3D = matchstick_scene.instantiate()
		add_child(matchstick) # put this before position and rotation!
		matchstick.global_position = Vector3(0, i+3, 0)
		matchstick.rotate_x(randf_range(0, 2*PI))
		matchstick.rotate_z(randf_range(0, 2*PI))
		
	game_state_chart.send_event("to_player_turn")

func _on_player_turn_state_entered():
	print("player turn state entered")
