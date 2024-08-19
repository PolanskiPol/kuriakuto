# Kuriakuto for Godot 4.x
##### Made by Polanski

Kuriakuto is a plugin for Godot to integrate reactivity in a similar fashion to JavaScript frameworks like Vue or React.

The aim of this project is to ease communication between variables and create reactivity to changes.

## How to use Kuriakuto

### Installing
1. Download the latest release of Kuriakuto
2. Add the "kuriakuto" folder inside "addons" into your project's "res://addons/"
3. Go to your project settings and enable the Kuriakuto plugin

### Usage
IMPORTANT: Any reactive value declared with Kuriakuto **MUST** be declared inside the method _ready() or with the @ready tag.

#### KuriakutoCore
KuriakutoCore is a Singleton that is in charge of managing reactivity. Inside, there are different functions that you can use to handle reactivity:
- **sync(node : Node, property : String, kuriakuto_resource_name : String):** Syncs a KuriakutoResource (by name) to a node property. Every change to the KuriakutoResource's value will be reflected on the node's property.
- **desync(node : Node, property : String, kuriakuto_resource_name : String):** Desyncs a KuriakutoResource (by name) from the node property.
- **is_synced(node : Node, property : String, kuriakuto_resource_name : String):** Returns if KuriakutoResource (by name) is in sync.
- **watch(kuriakuto_resource_name : String, callable : Callable):** Watch (by name) for a specific KuriakutoResource value changes. Will react accordingly calling the given Callable.

#### Creating reactive values
Reactive values are values that are not linked to any property. To create reactivity with this kind of value, we need to use the **KValue** Class.
```gdscript
# KValue Class inits with the KValue's name, and its value.
@onready var kuriakuto_value : KValue = KValue.new("kuriakuto_value", 100)

func _ready() -> void:
  print(kuriakuto_value.value) # Prints "100"
  kuriakuto_value.value = 72
```

To modify the value of a KValue, you must use its "value" property to either write or read.

#### Creating reactive properties
Reactive properties are values that are linked to a property of a node. To create reactivity with this kind of value, we need to use the **KProperty** Class.
```gdscript
# Scene hierarchy:
# > SceneRoot (This script)
# >> TextEdit (text = "Hello world!")
#
# KProperty Class inits with the KProperty's name, the node where we take the value, and the property where we take the value.
@onready var kuriakuto_property : KProperty = KProperty.new("kuriakuto_property", $TextEdit, "text")

func _ready() -> void:
  print(kuriakuto_property.value) # Prints the "text" property from node $TextEdit, in this case, "Hello world!"
```

It is advised not to modify the "value" property of your defined KProperties directly, as it will change back to the value of the property of the linked node the following frame, it should be used to be read only.

#### Creating computed values
Computed values are complex values that are not linked to any property, and instead are calculated each time that they are read. This kind of value doesn't create reactivity, and we need to use the **KComputed** Class.
```gdscript
# KComputed Class inits with the KComputed's name, and its Callable, which is the method that calculates the value of the KComputed.
@onready var kuriakuto_computed : KComputed = KComputed.new("kuriakuto_computed", Callable(func() -> int: # The Callable must always return something
  return Time.get_unix_time_from_system() / 60 / 60 / 24 / 365 # Now, kuriakuto_computed.value will return the time that has passed since 1970/01/01 in years.
))
```

For safety, a KComputed value can't be set as it calls the given Callable internally, instead it is read-only.

#### Syncing reactive values with nodes
Syncing is an essential part of Kuriakuto. KValues and KProperties can be synced, meaning that each time that their values change, the given node property will also update to show the same value.
```gdscript
@onready var kuriakuto_value : KValue = KValue.new("kuriakuto_value", 100)
@onready var kuriakuto_property : KProperty = KProperty.new("kuriakuto_property", $TextEdit, "text")

func _ready() -> void:
  # KuriakutoCore.sync has the following params: The node to be synced, the property name of the node that will be synced, and the KValue/KProperty name used for reactivity
  KuriakutoCore.sync($Label1, "text", "kuriakuto_value") # Whenever kuriakuto_value.value changes, the text of $Label1 will change to reflect the same value
  KuriakutoCore.sync($Label2, "text", "kuriakuto_property") # Whenever kuriakuto_property.value changes, the text of $Label2 will change to reflect the same value
```
Additionally, you can sync a node instancing the node "KuriakutoNodeSync" as a child of said node:
1. Insert "KuriakutoNodeSync" as a child of the node to sync.
2. Configure KuriakutoNodeSync, kuriakuto_property is the name of KValue or KProperty and node_property is the property name of the node that will be synced.

Since KuriakutoCore is a Singleton, you can sync KValues and KProperties from different scripts in your code and add reactivity between different contexts and nodes that are in the same scene.

#### Watching reactive values
You can watch a KValue or KProperty to add behaviour when their values change, similar to Godot's native signal system.
```gdscript
@onready var kuriakuto_value : KValue = KValue.new("kuriakuto_value", 100)
@onready var kuriakuto_property : KProperty = KProperty.new("kuriakuto_property", $TextEdit, "text")

func _ready() -> void:
  KuriakutoCore.watch("kuriakuto_value", Callable(func() -> void:
    print("kuriakuto_value has changed") # Whenever kuriakuto_value.value changes, the given Callable is called
  ))
  KuriakutoCore.watch("kuriakuto_property", Callable(func() -> void:
    print("kuriakuto_property has changed") # Whenever kuriakuto_property.value changes, the given Callable is called
  ))
```

Since KuriakutoCore is a Singleton, you can watch KValues and KProperties from different scripts in your code and add reactivity between different contexts and nodes that are in the same scene.
