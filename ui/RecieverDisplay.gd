extends Control

class_name RecieverDisplay

signal joy_axis_selected(channel_index, joy_index)
signal joy_axis_inverted(channel_index, joy_index, invert_value)

export var channel = "" setget set_channel, get_channel
export var value = 1500 setget set_value, get_value
export var joy_axis = -1 setget set_joy_axis, get_joy_axis
export var channel_index = ""
export var inverted = false setget set_inverted, get_inverted

func _ready():
	var joy = get_node("OptionButton")

	for i in range(JOY_AXIS_MAX):
		joy.add_item("Axis %d" % i)
	
	joy.connect("item_selected", self, "joy_axis_selected")

func joy_axis_selected(index):
	joy_axis = index
	emit_signal("joy_axis_selected", channel_index, joy_axis)

func get_joy_axis():
	return joy_axis

func set_joy_axis(val):
	joy_axis = val
	var joy = get_node("OptionButton")
	joy.selected = val
	joy.select(val)

func get_channel():
	return channel

func set_channel(val):
	channel = val

	update()

func get_inverted():
	return inverted

func set_inverted(val):
	inverted = val

	var invert = RC.get_inverted()
	invert[channel_index] = 1 if val else 0
	RC.set_inverted(invert)
	$Invert.pressed = val
	
	update()

func get_value():
	return value

func set_value(val):
	value = val

	update()

func update():
	(get_node("Channel") as Label).text = channel
	(get_node("Value") as Label).text = String(value)
	(get_node("ProgressBar") as ProgressBar).value = value 
	.update()


func _on_Invert_toggled(button_pressed: bool):
	set_inverted(button_pressed)
	emit_signal("joy_axis_inverted", channel_index, joy_axis, button_pressed)
