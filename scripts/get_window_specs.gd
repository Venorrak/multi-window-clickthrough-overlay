extends Node2D

var size : Vector2 = Vector2.ZERO
var shape : PackedVector2Array = []

func _ready() -> void:
	var clickShape = get_node("clickShape")
	if clickShape != null && clickShape.is_class("CollisionPolygon2D"):
		shape = clickShape.polygon.duplicate()
		for i in shape.size():
			shape[i] = shape[i] + position
	
	match self.get_class():
		"Sprite2D":
			size = self.texture.get_size()
		"Node2D":
			if get_child(0).is_class("Control"): #recommend a panelContainer
				size = get_child(0).get_rect().size
			
	get_parent().setSpecs(
		{
			"size": size,
			"shape": shape
		}
	)
func _input(event: InputEvent) -> void:
	#print(event)
	pass
