extends Reference

class_name InputFrame

var throttle: float setget set_throttle, get_throttle
var pitch: float setget set_pitch, get_pitch
var yaw: float setget set_yaw, get_yaw
var roll: float setget set_roll, get_roll

var rates = [[], [], []]

var max_angle: float setget set_max_angle, get_max_angle

var armed = false setget set_arming_flag, get_arming_flag
var mode: int setget set_mode, get_mode

func _init():
  mode = Mode.ACRO

func set_frame(frame: InputFrame):
  throttle = frame.throttle
  pitch = frame.pitch
  yaw = frame.yaw
  roll = frame.roll
  rates = frame.rates
  max_angle = frame.max_angle
  mode = frame.mode

func set_throttle(value):
  throttle = value

func get_throttle():
  return throttle

func set_pitch(value):
  pitch = value

func get_pitch():
  return pitch

func set_yaw(value):
  yaw = value

func get_yaw():
  return yaw

func set_roll(value):
  roll = value

func get_roll():
  return roll

func set_rates(axis, rc_rate, rate, expo):
  rates[axis] = [rc_rate, rate, expo]

func get_rates():
  return rates

func set_max_angle(value):
  max_angle = value

func get_max_angle():
  return max_angle

func set_mode(value):
  mode = value

func get_mode():
  return mode

func set_arming_flag(value):
  mode = value

func get_arming_flag():
  return mode

func calculate_throttle():
  return throttle

func calculate_pitch():
  return BetaflightHelper.apply_actual_rates(0.0 - pitch, rates[0][0], rates[0][1], rates[0][2])

func calculate_yaw():
  return BetaflightHelper.apply_actual_rates(0.0 - yaw, rates[1][0], rates[1][1], rates[1][2])

func calculate_roll():
  return BetaflightHelper.apply_actual_rates(0.0 - roll, rates[2][0], rates[2][1], rates[2][2])

func to_string():
  return "[throttle: %d pitch: %d yaw: %d roll %d]" % [throttle, pitch, yaw, roll]
