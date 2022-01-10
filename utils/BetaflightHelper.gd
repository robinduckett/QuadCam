extends Object

class_name BetaflightHelper

const RC_RATE_INCREMENTAL = 14.6

static func constrain(amt: float, low: float, high: float) -> float:
  if amt < low:
    return low
  elif amt > high:
    return high
  else:
    return amt

static func apply_betaflight_rates(rc_command, rc_rate, rate, expo):
  if expo > 0.0:
    var expof = expo / 100.0
    rc_command *= pow(abs(rc_command), 3) * expof + rc_command * (1 - expof)
  
  var c_rate = rc_rate / 100.0
  if c_rate > 2.0:
    c_rate += RC_RATE_INCREMENTAL * (c_rate - 2.0)

  var angle_rate = 200.0 * c_rate * rc_command

  if rate > 0.0:
    var rc_super = 1.0 / (constrain(1.0 - (abs(rc_command) * (rate / 100.0)), 0.01, 1.0))
    angle_rate *= rc_super
  
  return angle_rate

static func apply_actual_rates(rc_command, rc_rate, rate, expo):
  var expof = expo / 100.0
  expof = abs(rc_command) * (pow(rc_command, 5) * expof + rc_command * (1 - expof))
  var center_sensitivity = rc_rate * 10.0
  var stick_movement = max(0, rate * 10.0 - center_sensitivity)
  var angle_rate = rc_command * center_sensitivity + stick_movement * expof
  return angle_rate
