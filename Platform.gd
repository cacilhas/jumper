extends Node2D

export(PackedScene) var GroundGrass
export(PackedScene) var GroundGrassSmall

var screen_size: Vector2
var started := false
var counter := 0.0
var y_slice: float
var next_platform: float
export(int) var speed: float
export(float) var accel: float
export(int) var platforms_per_screen: float
var factory: Dictionary
var sides: Array
var last_side := 0


func _ready():
	randomize()
	screen_size = get_viewport_rect().size
	var x_slice = screen_size.x / 3
	y_slice = screen_size.y / platforms_per_screen
	sides = [-x_slice, x_slice]
	factory = {true: GroundGrassSmall, false: GroundGrass}
	next_platform = -y_slice
	for _i in platforms_per_screen:
		_add_platform()


func _add_platform() -> void:
	var platform: Node2D = factory[randf() < 0.4].instance()
	platform.position = Vector2(sides[last_side], next_platform)
	next_platform -= y_slice
	last_side = (last_side + 1) % 2
	add_child(platform)


func _process(delta: float) -> void:
	if not started:
		return

	position.y += speed * delta
	counter += speed * delta
	speed += accel * delta

	if counter >= y_slice:
		counter -= y_slice
		_add_platform()


func _on_start() -> void:
	started = true


func _on_finish():
	started = false
