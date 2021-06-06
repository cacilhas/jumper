extends Node2D


func _input(event: InputEvent) -> void:
	if Input.is_action_pressed("ui_cancel"):
		get_tree().quit()
	if Input.is_action_just_pressed("ui_accept"):
		_on_restart()


func _on_restart():
	get_tree().reload_current_scene()
