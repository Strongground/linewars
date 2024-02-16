@tool
extends EditorPlugin

var base_from: Node2D = null
var selected_node: Node = null
var editor_interface: EditorInterface
var editor_selection: EditorSelection
var editor_viewport: Viewport
var scene_root: Node
var connect_button = Button.new()
var connection_mode : bool = false
var drawing_helper_script = preload("res://addons/level-editor/drawing_helper.gd")
var drawing_helper : DrawingHelper

func _enter_tree():
	# Create connection button
	self.connect_button.icon = preload("res://addons/level-editor/icon_path.png")
	self.connect_button.connect("pressed", Callable(self, "_on_button_pressed"))
	self.connect_button.disabled = true
	add_control_to_container(CONTAINER_CANVAS_EDITOR_MENU, connect_button)
	# Get the editor interface and related objects
	self.editor_interface = get_editor_interface()
	# Get scene root if scene is loaded
	scene_changed.connect(func(new_root:Node):
		if new_root:
			scene_root = new_root
			_add_drawing_helper()
	)
	self.editor_selection = editor_interface.get_selection()
	self.editor_viewport = editor_interface.get_editor_viewport_2d()
	# Connect to selection changed signal
	self.editor_selection.connect("selection_changed", Callable(self, "_on_selection_changed"))

func _add_drawing_helper():
	# Add drawing helper to the viewport
	self.drawing_helper = DrawingHelper.new(self, scene_root)
	self.drawing_helper.custom_minimum_size = Vector2(editor_viewport.size)
	self.drawing_helper.z_index = 999
	self.editor_viewport.add_child(self.drawing_helper)

# If selection changes, check if the selected node is a Base node, and if we are already in connection mode.
# If we are in connection mode, connect the selected node to the node that was selected before.
# If we are not in connection mode, enable the connect button if the selected node is a Base node.
func _on_selection_changed():
	self.selected_node = _get_selected_node()
	# A base node was already selected before...
	if self.selected_node && self.selected_node is Base:
		# and we are in connection mode already...
		if self.connection_mode:
			# connect the selected node to the node that was selected before
			#self.base_from.add_connection(self.selected_node.get_name())
			#self.selected_node.add_connection(self.base_from.get_name())
			self.base_from.connections.append(self.selected_node.get_name())
			self.selected_node.connections.append(self.base_from.get_name())
			# reset the connection mode, disable the connect button and reset the node variables
			self.connection_mode = false
			self.connect_button.disabled = true
			self.selected_node = null
			self.base_from = null
		# A base node was not selected before...
		else:
			# set origin node and enable the connect button
			self.base_from = self.selected_node
			self.connect_button.disabled = false
	else:
		self.connect_button.disabled = true

func _get_selected_node():
	var selection = editor_selection.get_selected_nodes()
	if selection.size() == 1:
		return selection[0]

func _on_button_pressed():
	if self.selected_node && self.selected_node is Base:
		self.connection_mode = true
		self.base_from = self.selected_node

func _exit_tree():
	remove_control_from_container(CONTAINER_CANVAS_EDITOR_MENU, self.connect_button)
	self.connect_button.queue_free()