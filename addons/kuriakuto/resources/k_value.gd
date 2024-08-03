class_name KValue
extends KResource

signal value_changed

# Private
var _property_name : String

# Public
var value : Variant : 
	set(new_value):
		value = new_value
		emit_signal("value_changed")
	get:
		return value
		
func get_kuriakuto_name() -> String:
	return _property_name
