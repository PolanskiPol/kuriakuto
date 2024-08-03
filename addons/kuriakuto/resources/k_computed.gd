class_name KComputed
## Kuriakuto reactive value[br]
## The value of KuriakutoComputed is the result of its given callable[br]
## Specially useful when pre-computing complex values[br]
##
## [codeblock]
## @onready var health : int = 100
## @onready var level : int = 3
## @onready var armor : int = 25
## @onready var damage : KuriakutoComputed = KuriakutoComputed.new("damage", func() -> int:
##     return armor / (level * 1.1)  
## ))
## [/codeblock]
extends KResource

# Private
var _property_name : String
var _callable : Callable

# Public
## value is always null, and when retrieving it, it actually returns the result of the given callable
var value :
	get:
		return _callable.call()
	set(new_value): 
		return # Never set the KuriakutoComputed value for safety
		
func _init(name : String, value : Callable) -> void:
	self._property_name = name
	self._callable = value
	KuriakutoCore.register(self)

func get_kuriakuto_name() -> String:
	return _property_name
