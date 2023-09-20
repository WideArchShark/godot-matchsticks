extends Label

func _on_state_manager_match_count_changed(new_match_count):
	text = "Matches Remaining: %d" % new_match_count
