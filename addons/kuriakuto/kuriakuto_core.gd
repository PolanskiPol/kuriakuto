extends Node

signal kuriakuto_resource_added(kuriakuto_resource : KResource)

enum KuriakutoWarns {
	KURIAKUTO_RESOURCE_DOESNT_EXIST,
	KURIAKUTO_PROPERTY_DOESNT_EXIST,
	KURIAKUTO_VALUE_DOESNT_EXIST,
	KURIAKUTO_OBSERVABLE_DOESNT_EXIST,
}

## List of all declared 
var _kuriakuto_resources : Dictionary
## Kuriakuto Properties are values linked to a node property, with their own logic
var _kuriakuto_properties : Dictionary
var _observables : Dictionary

func _warn(error : KuriakutoWarns, extra : Variant = null) -> void:
	match error:
		KuriakutoWarns.KURIAKUTO_PROPERTY_DOESNT_EXIST:
			push_warning("KReactive \"" + extra + "\" does not exist")
		KuriakutoWarns.KURIAKUTO_OBSERVABLE_DOESNT_EXIST:
			push_warning("Observable \"" + extra + "\" does not exist")
			
func _get_unique_id(node : Node) -> String:
	var node_bytes : int = 0
	var owner_bytes : int = 0
	for byte in var_to_bytes(node.name):
		node_bytes += byte
	for byte in var_to_bytes(node.owner.name):
		owner_bytes += byte
	var uuid_int : int = (node.owner.name.length() + owner_bytes) * (node.name.length() + node_bytes)
	return str(uuid_int) + "_" + node.owner.name + "_" + node.name
	
	
	
## Register a new Kuriakuto Property, Computed or Value, available for global use
func register(kuriakuto_resource : KResource) -> void:
	if(kuriakuto_resource is KProperty):
		_kuriakuto_properties[kuriakuto_resource.get_kuriakuto_name()] = kuriakuto_resource
		_kuriakuto_resources[kuriakuto_resource.get_kuriakuto_name()] = _kuriakuto_properties[kuriakuto_resource.get_kuriakuto_name()]
	else:
		_kuriakuto_resources[kuriakuto_resource.get_kuriakuto_name()] = kuriakuto_resource
	emit_signal("kuriakuto_resource_added", kuriakuto_resource)
		
## Deregister (by name) an existing KuriakutoReactive
func deregister(kuriakuto_resource_name : String) -> void:
	_kuriakuto_resources.erase(kuriakuto_resource_name)
	
## Watch (by name) for a specific KuriakutoReactive value changes
## Will react accordingly calling the declared Callable
func watch(kuriakuto_resource_name : String, callable : Callable) -> void:
	if(!_kuriakuto_resources.has(kuriakuto_resource_name)): 
		_warn(KuriakutoWarns.KURIAKUTO_PROPERTY_DOESNT_EXIST, kuriakuto_resource_name)
		return
	_kuriakuto_resources[kuriakuto_resource_name].value_changed.connect(callable)
	
## Return (by name) the value of a registered KuriakutoReactive
## When getting the value of a KuriakutoReactive, use this method instead of [method get_kuriakuto_resource]
func get_value(kuriakuto_resource_name : String) -> Variant:
	if(!_kuriakuto_resources.has(kuriakuto_resource_name)) : return null
	return _kuriakuto_resources[kuriakuto_resource_name].value
	
## Return (by name) a registered KuriakutoReactive
func get_kuriakuto_resource(kuriakuto_resource_name : String) -> Variant:
	if(!_kuriakuto_resources.has(kuriakuto_resource_name)) : return null
	return _kuriakuto_resources[kuriakuto_resource_name]
	
## Return all the KuriakutoReactive properties that are registered
func get_kuriakuto_resources() -> Dictionary:
	return _kuriakuto_resources
	
## Sync a KuriakutoReactive property (by name) to a node property
## Every change to the KuriakutoReactive's value will be reflected on the node's property
func sync(node : Node, property : String, kuriakuto_resource_name : String) -> void:
	var uuid : String = _get_unique_id(node) + "_" + property + "_" + kuriakuto_resource_name
	if(!_kuriakuto_resources.has(kuriakuto_resource_name)): 
		_warn(KuriakutoWarns.KURIAKUTO_PROPERTY_DOESNT_EXIST, kuriakuto_resource_name)
		return
	var callable : Callable = Callable(func() -> void:
		node.set(property, get_value(kuriakuto_resource_name))
	)
	_kuriakuto_resources[kuriakuto_resource_name].value_changed.connect(callable)
	_observables[uuid] = callable
	
## Returns if KuriakutoReactive property (by name) is in sync
func is_synced(node : Node, property : String, kuriakuto_resource_name : String) -> void:
	return _observables.has(node.name + "_" + property + "_" + kuriakuto_resource_name)
	
## Desyncs a KuriakutoReactive property (by name) to a node property
func desync(node : Node, property : String, kuriakuto_resource_name : String) -> void:
	var uuid : String = _get_unique_id(node) + "_" + property + "_" + kuriakuto_resource_name
	if(!_kuriakuto_resources.has(kuriakuto_resource_name)): 
		_warn(KuriakutoWarns.KURIAKUTO_PROPERTY_DOESNT_EXIST, kuriakuto_resource_name)
		return
	if(!_observables.has(uuid)): 
		_warn(KuriakutoWarns.KURIAKUTO_OBSERVABLE_DOESNT_EXIST, uuid)
		return
	_kuriakuto_resources[kuriakuto_resource_name].value_changed.disconnect(_observables[uuid])
	_observables.erase(uuid)
	
func reset() -> void:
	_observables.clear()
	_kuriakuto_resources.clear()
	_kuriakuto_properties.clear()
	
	
func _process(delta : float) -> void:
	for kuriakuto_property in _kuriakuto_properties.keys():
		if(_kuriakuto_properties[kuriakuto_property].value != _kuriakuto_properties[kuriakuto_property].get_node_value()):
			_kuriakuto_properties[kuriakuto_property].value = _kuriakuto_properties[kuriakuto_property].get_node_value()
			_kuriakuto_resources[kuriakuto_property] = _kuriakuto_properties[kuriakuto_property]
