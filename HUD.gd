extends Control

onready var title := $Title
onready var game_over := $GameOver
onready var game_over_audio := $GameOverAudio
onready var score := $Score
onready var shadow := $Shadow
onready var timer := $Timer
var score_value := 0


func _process(delta: float) -> void:
	var txt = "%04d" % score_value
	score.text = txt
	shadow.text = txt


func _on_timeout():
	score_value += 1


func _on_dead():
	timer.stop()
	game_over.show()
	game_over_audio.play()


func _on_start():
	title.hide()
	timer.start()
