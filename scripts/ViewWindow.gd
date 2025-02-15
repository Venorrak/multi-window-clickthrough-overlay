extends Window

@onready var _Camera: Camera2D = $ViewCamera

var world_offset: = Vector2i.ZERO
var last_position: = Vector2i.ZERO
var velocity: = Vector2i.ZERO
var focusChild = null #object being followed

func _ready() -> void:
	_Camera.anchor_mode = Camera2D.ANCHOR_MODE_FIXED_TOP_LEFT
	transient = true

func setChild(fetus : Node2D) -> void: #child received from world.gd
	focusChild = fetus
	focusChild.connect("specsChanged", receiveSpecs)

func _process(delta: float) -> void:
	if focusChild == null: # if the child doesn't exist, delete window
		queue_free()
	else:
		#predict where the window will be to reduce weird border on window
		velocity = position - last_position
		last_position = position
		_Camera.position = focusChild.position
		position = focusChild.position + Vector2(world_offset)

func receiveSpecs(specs : Dictionary) -> void:
	#specs = {
		#size = Vector2(128, 128),
		#shape = PackedVector2Array([])
	#}
	#apply specs to window
	size = specs["size"]
	mouse_passthrough_polygon = specs["shape"]

func get_camera_pos_from_window()->Vector2i:
	return position + velocity - world_offset

func _on_window_input(event: InputEvent) -> void:
	focusChild.passInput(event)
