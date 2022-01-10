extends RigidBody

class_name QuadEntity

export(bool) var active
export(int) var camera_angle = 35 setget set_camera_angle, get_camera_angle
export(float) var thrust = 10
export(float) var thrust_curve = 1.5
export(float) var width = 0.55
export(float) var height = 0.3

var frame
var old_pos = Vector3.ZERO

var counter = 0

var props = []

func _init():
	frame = InputFrame.new();

func check_settings():
	var settings = get_node("/root/RC").get_settings()
	if settings[0] == 0 and has_node("Camera/motion_blur"):
		get_node("Camera/motion_blur").queue_free()
	if settings[1] == 0 and has_node("Camera/LensFlare"):
		get_node("Camera/LensFlare").queue_free()

func _process(delta):
	var prop_rotation = Vector3(0.0, deg2rad((1.0 + (frame.get_throttle() / 2.0)) * thrust) * delta, 0.0)

	$PropA.rotation -= prop_rotation
	$PropB.rotation += prop_rotation
	$PropA2.rotation -= prop_rotation
	$PropB2.rotation += prop_rotation

	# for prop in props:
	# 	if prop.is_in_group("ccw"):
	# 		prop.rotation -= prop_rotation
	# 	else:
	# 		prop.rotation += prop_rotation

	# if counter > 5:
	# 	check_settings()

	# 	counter = 0

	# 	var a = get_global_transform().basis

	# 	var up = a.xform(Vector3.UP)
	# 	var thrust_force = up * thrust * pow((1.0 + frame.get_throttle()) / 2.0, thrust_curve)
		
		
	# 	(get_node("Control/Speed") as Label).text = "Thrust: %1.2f, %1.2f, %1.2f (%1.2f) (N)" % [
	# 		thrust_force.x, thrust_force.y, thrust_force.z, linear_velocity.y
	# 	]

	# 	var new_pos = global_transform.origin
	# 	var current_distance = new_pos - old_pos

	# 	var absolute_distance = current_distance.abs()

	# 	var speed = absolute_distance / (10.0 * delta)

	# 	var speed_mps = speed / 5.0
	# 	var speed_kph = speed_mps * 3.6

	# 	(get_node("Control/Speed2") as Label).text = "Airspeed: %1.0f km/h" % speed_kph.length()

	# 	old_pos = new_pos

	# counter += 1
	

func set_camera_angle(val):
	camera_angle = val
	get_node("Camera").rotation_degrees = Vector3(camera_angle, 0, 0)

func get_camera_angle():
	return camera_angle

func _integrate_forces(state):
	frame.set_frame(RC.get_frame())

	if frame.get_mode() == Mode.ACRO:
		var av = Vector3(
			frame.calculate_pitch(),
			frame.calculate_yaw(),
			frame.calculate_roll()
		) * state.step

		var a = get_global_transform().basis

		state.set_angular_velocity(a.xform(av) / 10.0)

		var up = a.xform(Vector3.UP)
		var thrust_force
		# transform = transform.orthonormalized()
		if RC.get_settings()[4] == 1:
			var throt = frame.get_throttle() if frame.get_throttle() > 0.0 else 0.0
			thrust_force = up * thrust * pow(throt, thrust_curve)
		else:
			thrust_force = up * thrust * pow((1.0 + frame.get_throttle()) / 2.0, thrust_curve)

		# var yaw_thrust = up * abs(frame.calculate_yaw(0.05) * thrust * 0.002)

		# if frame.get_throttle() < -0.9 && linear_velocity.y:
		# 	thrust_force.y = 
		
		var motors = [
			Vector3(1.0, 0.0, 1.0),
			Vector3(-1.0, 0.0, 1.0),
			Vector3(1.0, 0.0, -1.0),
			Vector3(-1.0, 0.0, -1.0),
		]

		var total_thrust = thrust_force / 4.0

		var motor_force = [
			1.0, 1.0, 1.0, 1.0
		]

		# if thrust_force.length() != INF:
		# state.add_central_force((thrust_force + yaw_thrust))
		state.add_force(motor_force[0] * total_thrust, motors[0])
		state.add_force(motor_force[1] * total_thrust, motors[1])
		state.add_force(motor_force[2] * total_thrust, motors[2])
		state.add_force(motor_force[3] * total_thrust, motors[3])
		# 	pass
		
		state.integrate_forces()
