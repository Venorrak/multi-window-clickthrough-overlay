extends RigidBody2D
class_name window_object

@export var numberOfSavedPositions : int
@export var bodyCollision : CollisionPolygon2D

var windowSize : Vector2 = Vector2.ZERO
var lastPositions : Array = []

signal specsChanged
signal inputReceived

func passInput(event : InputEvent) -> void:
	if event is InputEventMouseButton:
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				var backEndEvent : InputEventMouseButton = event.duplicate(true) # need this so the menu work in the window
				backEndEvent.position = backEndEvent.position + position
				get_viewport().push_input(backEndEvent, true)
				
				if event.pressed:
					freeze = true
					lastPositions = [] #reset velocity
				else:
					PhysicsServer2D.body_set_state( #the rigidbody has to be moved with the physics engine so it stay where it is after you unfreeze it
						get_rid(),
						PhysicsServer2D.BODY_STATE_TRANSFORM,
						Transform2D.IDENTITY.translated(position)
					)
					linear_velocity = calculateVelocity()
					freeze = false

	if event is InputEventMouseMotion: #move the object if you're dragging it
		if freeze == true && event.button_mask == MOUSE_BUTTON_LEFT:
			if event.relative.length() < 500:
				position += event.relative

func _physics_process(delta: float) -> void:
	amIOutOfBounds()# if it's out of the screen remove it
	
	if freeze == true: #save positions to calculate velocity later
		lastPositions.append(position)
		if lastPositions.size() > numberOfSavedPositions + 1:
			lastPositions.pop_front()

func calculateVelocity() -> Vector2:
	var velocities : Array = []
	var force : float = 0
	
	for i in lastPositions.size() - 1:
		velocities.append(lastPositions[i + 1] - lastPositions[i])
		
	for vec in velocities:
		force += vec.length()
	# the last velocity chooses the direction and the force is the addition of all the vectors
	return velocities[-1].normalized() * force 

func amIOutOfBounds() -> void:
	var screenRec : Vector2i = DisplayServer.screen_get_size(0)
	if position.x > screenRec.x || position.x < 0 - windowSize.x || position.y > screenRec.y || position.y < 0 - windowSize.y:
		queue_free()

func getFourCorners(size : Vector2) -> PackedVector2Array:
	var corners : Array = []
	corners.append(Vector2(0, 0))
	corners.append(Vector2(size.x, 0))
	corners.append(Vector2(size.x, size.y))
	corners.append(Vector2(0, size.y))
	return PackedVector2Array(corners)

func setSpecs(specs : Dictionary) -> void:
	#specs = {
		#size = Vector2(128, 128),
		#shape = PackedVector2Array([])
	#}
	windowSize = specs["size"]
	
	#define the shape of the window shapethrough
	if specs["shape"] == PackedVector2Array([]):
		bodyCollision.polygon = getFourCorners(specs["size"])
	else:
		bodyCollision.polygon = specs["shape"]

	specsChanged.emit(specs) #send specs to window
