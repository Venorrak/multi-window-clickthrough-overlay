extends Node

@onready var _MainWindow: Window = get_window()
@onready var _MainScreen: int = _MainWindow.current_screen

@export var view_window: PackedScene
@export var window1 : PackedScene
@export var window2 : PackedScene
@export var window3 : PackedScene
@export var sceneRoot : Node2D #contains the scene only visible in the floating windows

var world_offset: = Vector2i.ZERO

func _ready() -> void:
	_MainWindow.set_canvas_cull_mask_bit(1, false) #make sceneRoot invisibe on main window
	
	world_offset = DisplayServer.screen_get_size(1)#TODO change this world offset in case you have only one monitor
	world_offset.y = 0
	
	create_new_body( window1.instantiate()) # create basic examples on your screen
	create_new_body(window2.instantiate())
	create_new_body(window3.instantiate())
	
func create_new_body(object, position : Vector2i = DisplayServer.screen_get_size(0)/2) -> void:
	var new_window : Window = view_window.instantiate()
	
	new_window.world_2d = _MainWindow.world_2d #set the new_window so they all show the same world
	new_window.world_3d = _MainWindow.world_3d
	new_window.world_offset = world_offset
	
	object.position = position
	new_window.setChild(object)# say to the window what object it is following
	
	sceneRoot.add_child.call_deferred(object)
	add_child.call_deferred(new_window)
