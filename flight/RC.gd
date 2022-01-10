extends Node

export var inverted = [0, 0, 0, 0] setget set_inverted, get_inverted
export var assignments = [] setget set_assignments, get_assignments
export var joy_device = 0 setget set_joy_device, get_joy_device
export var settings = [1, 1, 1, 1, 1] setget set_settings, get_settings

enum Channels {
	Roll,
	Pitch,
	Yaw,
	Throttle,
	AUX1,
	AUX2,
	AUX3,
	AUX4,
	AUX5,
	AUX6,
}

var frame: InputFrame

func set_settings(val):
	settings = val

func get_settings():
	return settings

static func get_rc_value(axis_value):
	return round(1000.0 + ((axis_value + 1.0) * 1000.0) / 2.0)

func rc_command(channel):
	var axis = 0.0

	if inverted[channel] == 0:
		axis = Input.get_joy_axis(joy_device, assignments[channel])
	else:
		axis = 0.0-Input.get_joy_axis(joy_device, assignments[channel])
	
	if settings[4] == 1 and channel == Channels.Throttle:
		axis = (axis - 0.5) * 2.0 if axis > 0.0 else -1.0
	
	return axis

func get_joy_device():
	return joy_device

func set_joy_device(val):
	joy_device = val

func get_assignments():
	return assignments

func set_assignments(val):
	assignments = val

func get_inverted():
	return inverted
	
func set_inverted(val):
	inverted = val

func get_frame():
	return frame

func set_rates(axis, rc_rate, rate, expo):
	frame.set_rates(axis, rc_rate, rate, expo)

func _ready():
	frame = InputFrame.new()

	frame.set_mode(Mode.ACRO)
	frame.set_throttle(-1.0)
	frame.set_pitch(1.0)
	frame.set_roll(1.0)
	frame.set_yaw(1.0)

func process_rc_command(_delta):
	if assignments.size() > 0:
		frame.set_throttle(rc_command(Channels.Throttle))
		frame.set_pitch(rc_command(Channels.Pitch))
		frame.set_roll(rc_command(Channels.Roll))
		frame.set_yaw(rc_command(Channels.Yaw))
	
func _physics_process(delta):
	process_rc_command(delta)
