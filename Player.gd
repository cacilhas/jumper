extends KinematicBody2D

signal start()
signal dead()

onready var sprite := $Sprite
onready var jump_audio := $JumpAudio
var screen_size: Vector2
var moving := Vector2(0, 1)
var started := false
export(Vector2) var speed: Vector2
var jump := {
	force = -1.0,
	jumping = false,
	decay = 1.0,
	grounded = true,
}


func _ready() -> void:
	screen_size = get_viewport_rect().size


func _process(delta: float) -> void:
	if moving.x < 0:
		sprite.flip_h = true
	elif moving.x > 0:
		sprite.flip_h = false

	if jump.jumping:
		sprite.animation = "jump"
	elif moving.x == 0:
		sprite.animation = "ready"
	else:
		sprite.animation = "walk"

	move_and_collide(Vector2(moving.x, 0) * speed.x * delta)
	position.x = clamp(position.x, 0, screen_size.x)

	moving.y = clamp(moving.y + delta * jump.decay, -1, 1)
	var body := move_and_collide(Vector2(0, moving.y) * speed.y * delta)
	if body != null:
		jump.jumping = false
		if body.position.y > position.y:
			jump.grounded = true
		elif moving.y < 0:
			moving.y = 0
	position.y = clamp(position.y, 0, screen_size.y * 2)

	if position.y > screen_size.y:
		emit_signal("dead")
		queue_free()


func _input(event: InputEvent) -> void:
	moving.x = 0

	if event is InputEventKey:
		if Input.is_action_pressed("ui_right"):
			moving.x += 1
		if Input.is_action_pressed("ui_left"):
			moving.x -= 1
		if (Input.is_action_just_pressed("ui_up") or Input.is_action_just_pressed("ui_select")):
			_jump()

	elif event is InputEventScreenTouch:
		if event.position.x < position.x:
			moving.x -= 1
		elif event.position.x > position.x:
			moving.x += 1

		if event.position.y < position.y:
			_jump()


func _jump() -> void:
	if not jump.grounded:
		return

	moving.y = jump.force
	jump.jumping = true
	jump.grounded = false
	if not started:
		started = true
		emit_signal("start")
	jump_audio.play()
