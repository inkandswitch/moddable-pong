@tool
extends Node2D

var _default_shape: RectangleShape2D = RectangleShape2D.new()

## The spawn will happen at a random point inside this area.
@export var spawn_area: Shape2D = _default_shape

## How many seconds the spawned component will stay until automatically removed. If zero, it won't be automatically removed.
@export_range(0.0, 10.0, 0.1, "or_greater") var life_time: float = 3.0

## The period of time in seconds to spawn another component. If zero, they won't spawn automatically. See the spawn() method.
@export_range(0.0, 10.0, 0.1, "or_greater") var spawn_frequency: float = 0.0

const _DEBUG_COLOR = Color(1.0, 0.3, 0.7, 0.2)
const _DEFAULT_SHAPE_SIZE = Vector2(200, 200)

var _nodes = []


# Called when the node enters the scene tree for the first time.
func _ready():
	_default_shape.set_size(_DEFAULT_SHAPE_SIZE)
	update_configuration_warnings()

	if Engine.is_editor_hint():
		return
	
	for node in get_children():
		if node is Node2D:
			remove_child(node)
			_nodes.append(node)

	if spawn_frequency != 0.0:
		var timer = Timer.new()
		add_child(timer)
		timer.wait_time = spawn_frequency
		timer.timeout.connect(spawn)
		timer.start()


func _get_configuration_warnings():
		var warnings = []
		if get_child_count() == 0:
			warnings.append("Nothing to spawn. Please add childrens to the Spawner node.")
		return warnings


func _draw():
	if spawn_area != null:
		if Engine.is_editor_hint() or get_tree().is_debugging_collisions_hint():
			spawn_area.draw(get_canvas_item(), _DEBUG_COLOR)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Engine.is_editor_hint() or get_tree().is_debugging_collisions_hint():
		queue_redraw()


func _get_random_point_in_area() -> Vector2:
	var spawn_rect = spawn_area.get_rect()
	var x = randf_range(spawn_rect.position.x, spawn_rect.position.x + spawn_rect.size.x)
	var y = randf_range(spawn_rect.position.y, spawn_rect.position.y + spawn_rect.size.y)
	return Vector2(x, y)


func _get_random_node():
	var i = randi() % _nodes.size()
	return _nodes[i]


func spawn():
	var node = _get_random_node().duplicate()
	if life_time != 0.0:
		var timer = get_tree().create_timer(life_time)
		timer.timeout.connect(node.queue_free)
	if spawn_area != null:
		node.position = _get_random_point_in_area()
	call_deferred("add_child", node)
	return node
