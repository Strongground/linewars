extends Node2D

@onready var game : Node = get_node("/root/game")

func _ready():
	pass

func _process(_delta):
	queue_redraw()

# Paint connecting lines between bases, according to the bases "connections" property
func _draw():
	if game == null:
		return
	for i in range(game.get_child_count()):
		var node = game.get_child(i)
		if node is Base:
			for j in range(node.get_connections().size()):
				var target = node.connections[j]
				draw_line(node.global_position, target.global_position, Color(1,1,1,0.25), 2, true)
