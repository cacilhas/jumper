extends KinematicBody2D

signal start()
signal dead()

const slide := 8
const gravity := 3000.0
const speed := 640

var jump_force := 1400.0

onready var sprite := $Sprite
onready var jump_audio := $JumpAudio
onready var screen_size := get_viewport_rect().size
onready var vforce := gravity
onready var target := position.x
var jump := false
var grounded := true
var started := false


func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		_process_screen_touch(event)


func _keyboard() -> void:
	if Input.is_action_pressed("ui_left"):
		target = position.x - slide
	if Input.is_action_pressed("ui_right"):
		target += position.x + slide
	if Input.is_action_just_pressed("ui_select"):
		_jump()


func _process_screen_touch(event: InputEventScreenTouch) -> void:
	target = event.position.x
	if abs(target - position.x) < 5:
		target = position.x
	if position.y - event.position.y > 64:
		_jump()


func _jump():
	if jump or not grounded:
		return
	grounded = false
	jump = true
	vforce = -jump_force
	if not started:
		emit_signal("start")
		started = true
	jump_audio.play()


func _process(delta: float) -> void:
	_keyboard()
	var dx := target - position.x
	if -5 < dx and dx < 5:
		dx = 0
		target = position.x
	dx = clamp(dx, -1, 1)

	if dx < 0:
		sprite.flip_h = true
	elif dx > 0:
		sprite.flip_h = false

	if jump:
		sprite.animation = "jump"
	elif not grounded:
		sprite.animation = "hurt"
	elif dx == 0:
		sprite.animation = "ready"
	else:
		sprite.animation = "walk"

	move_and_collide(Vector2(dx * speed * delta, 0))
	position.x = clamp(position.x, 0, screen_size.x)

	vforce += clamp(gravity * delta, -1000, gravity)
	var body = move_and_collide(Vector2(0, vforce * delta))
	if body != null:
		jump = false
		grounded = abs(body.normal.y + 1) < 0.125
		vforce = clamp(vforce, 0, gravity)

	if position.y > screen_size.y:
		emit_signal("dead")
		queue_free()
