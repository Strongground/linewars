extends Control
class_name DrawingHelper

var game : Node2D = null
var plugin : EditorPlugin
var scene_root : Node

func _init(plugin:EditorPlugin, scene_root:Node):
	self.plugin = plugin
	self.scene_root = scene_root
	print("Got scene root: ", scene_root)

func _ready():
	game = self.scene_root
	queue_redraw()
	print(game)

func _process(_delta):
	queue_redraw()

func _draw():
	if game == null:
		return
	for i in range(game.get_child_count()):
		var node = game.get_child(i)
		if node is Base:
			for j in range(node.connections.size()):
				var target = node.connections[j]
				target = game.get_node(target)
				draw_line(node.global_position, target.global_position, Color(1,1,1,0.25), 2, true)