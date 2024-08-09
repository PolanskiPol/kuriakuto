@tool
extends EditorPlugin

## This is an empty script so Godot detects Kuriakuto as a Plugin and adds the Kuriakuto custom nodes to the "Add node" window.

func _enter_tree() -> void:
	add_autoload_singleton("KuriakutoCore", "kuriakuto_core.gd")
	
func _exit_tree() -> void:
	remove_autoload_singleton("KuriakutoCore")
