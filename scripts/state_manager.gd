extends Node

@onready var matchstick_scene: PackedScene = preload("res://assets/matchstick.tscn")
@onready var player_choices = $"../CanvasLayer/PlayerChoiceBoxContainer"
@onready var status_label = $"../CanvasLayer/StatusLabel"
@onready var game_state_chart: StateChart = $"../GameStateChart"
@onready var new_game_button = $"../CanvasLayer/NewGameButton"

@export var min_matches: int = 20
@export var max_matches: int = 35
var current_match_count: int

var turn: String = "player"

signal match_count_changed(new_match_count: int)

#func _display_status(display_text: String, duration: int):
#	status_label.visible = true
#	status_label.text = display_text
#	await get_tree().create_timer(duration).timeout
#	status_label.visible = false

	
func _on_init_state_entered():
	print("init state entered")
	current_match_count = randi_range(min_matches, max_matches)
	match_count_changed.emit(current_match_count)
	status_label.visible = true
	status_label.text = "Players Turn"
	
	for i in range(current_match_count):
		var matchstick: RigidBody3D = matchstick_scene.instantiate()
		add_child(matchstick)
		matchstick.add_to_group("matches")
		matchstick.global_position = Vector3(0, i+4, 0)
		matchstick.rotate_x(randf_range(0, 2*PI))
		matchstick.rotate_z(randf_range(0, 2*PI))
		
	game_state_chart.send_event("to_player_turn")

func _on_player_turn_state_entered():
	print("player turn state entered")
	status_label.visible = false
#	await _display_status("Players Turn", 2)
	player_choices.visible = true

func _on_player_choice_button_pressed(match_count: int):
	player_choices.visible = false
#	_display_status("Player takes %d match(es)" % match_count, 3)

	for i in range(match_count):
		get_tree().get_nodes_in_group("matches")[i].queue_free()
	
	current_match_count -= match_count
	match_count_changed.emit(current_match_count)
#	turn = "player"
	game_state_chart.send_event("to_evaluate")

func _on_evaluate_state_entered():
	if current_match_count > 1 && turn == "player":
		turn = "computer"
		status_label.visible = true
		status_label.text = "Computers Turn"
		game_state_chart.send_event("to_computer_turn")
	elif current_match_count > 1 && turn == "computer":
		print("got here")
		turn = "player"
		status_label.visible = true
		status_label.text = "Players Turn"
		game_state_chart.send_event("to_player_turn")
	elif current_match_count == 1:
		status_label.visible = true
		status_label.text = "%s wins!" % turn
		new_game_button.visible = true
		
func _on_computer_turn_state_entered():
	print("Computer turn")
	var matches_to_take = max(1, (current_match_count - 1) % 4)
	print(matches_to_take)
	status_label.visible = true
	status_label.text = "Computer takes %d match(es)" % matches_to_take
	current_match_count -= matches_to_take

	for i in range(matches_to_take):
		get_tree().get_nodes_in_group("matches")[i].queue_free()

	match_count_changed.emit(current_match_count)
	
	game_state_chart.send_event("to_evaluate")
	
func _on_new_game_button_pressed():
	get_tree().reload_current_scene()
