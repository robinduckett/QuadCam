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

var camera
var camera2

var visual

var prev_collide

func _init():
	frame = InputFrame.new();

func check_settings():
	var settings = RC.get_settings()
	print(settings)
	if settings[0] == 0 and has_node("Visual/Camera/motion_blur"):
		get_node("Visual/Camera/motion_blur").queue_free()
	if settings[1] == 0 and has_node("Visual/Camera/LensFlare"):
		get_node("Visual/Camera/LensFlare").queue_free()

func _ready():
	camera = get_node("Visual/Camera")
	camera2 = get_parent().get_parent().get_node("Viewport/QuadEntity/Visual/Camera")
	visual = get_parent().get_parent().get_node("Viewport/QuadEntity")

	var rc_camera_angle = RC.get_settings()[5]

	set_camera_angle(rc_camera_angle)

	props.push_back(get_parent().get_parent().get_node("Viewport/QuadEntity/Visual/PropA"))
	props.push_back(get_parent().get_parent().get_node("Viewport/QuadEntity/Visual/PropB"))
	props.push_back(get_parent().get_parent().get_node("Viewport/QuadEntity/Visual/PropA2"))
	props.push_back(get_parent().get_parent().get_node("Viewport/QuadEntity/Visual/PropB2"))

func _process(delta):
	if camera:
		camera.rotation_degrees = Vector3(camera_angle, 0, 0)
		camera2.rotation_degrees = camera.rotation_degrees
		if camera.fov != RC.get_settings()[6]:
			camera.fov = RC.get_settings()[6]
			camera2.fov = camera.fov

	var prop_rotation = Vector3(0.0, deg2rad((1.0 + (frame.get_throttle() / 2.0)) * thrust) * delta, 0.0)

	props[0].rotation -= prop_rotation
	props[1].rotation += prop_rotation
	props[2].rotation -= prop_rotation
	props[3].rotation += prop_rotation

	visual.global_transform = get_global_transform()

func set_camera_angle(val):
	camera_angle = val

	check_settings()

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
		var modified_thrust = thrust * self.gravity_scale
		var thrust_force
		# transform = transform.orthonormalized()
		if RC.get_settings()[4] == 1:
			var throt = frame.get_throttle() if frame.get_throttle() > 0.0 else 0.0
			thrust_force = up * modified_thrust * pow(throt, thrust_curve)
		else:
			thrust_force = up * modified_thrust * pow((1.0 + frame.get_throttle()) / 2.0, thrust_curve)

		var yaw_thrust = up * abs((frame.calculate_yaw() * 0.01) * modified_thrust * 0.002)
		
		thrust_force += yaw_thrust
		
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

		var motor_force_modifier = 1.5

		total_thrust *= motor_force_modifier

		state.add_force(motor_force[0] * total_thrust, motors[0])
		state.add_force(motor_force[1] * total_thrust, motors[1])
		state.add_force(motor_force[2] * total_thrust, motors[2])
		state.add_force(motor_force[3] * total_thrust, motors[3])

		var lvy = state.linear_velocity.y
		state.linear_velocity *= pow(1 - 0.6, state.step)

		if state.linear_velocity.y < 0:
			state.linear_velocity.y = lvy # don't damp gravity

		state.integrate_forces()
