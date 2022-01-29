extends Control

var settings_file = "user://settings.save"

var channels = [
	"Roll",
	"Pitch",
	"Yaw",
	"Throttle",
	# "AUX 1",
	# "AUX 2",
	# "AUX 3",
	# "AUX 4",
	# "AUX 5",
	# "AUX 6"
]

var main_scene = "res://scenes/Map.tscn"

var joy_device = 0

var assignments = [0, 1, 3, 2, 4, 5, 6, 7, 8, 9]

var RecieverDisplay = preload("res://ui/RecieverDisplay.tscn")

var queue = preload("res://utils/Loader.gd").new()

var loader
var wait_frames
var time_max = 50

func _ready():
	var _ok = $HTMLLabel.connect("meta_clicked", self, "_on_RichTextLabel_meta_clicked")
	_ok = Input.connect("joy_connection_changed", self, "_on_joy_connection_changed")

	RC.set_joy_device(joy_device)

	if OS.has_feature('JavaScript'):
		$HTMLLabel.visible = true
	else:
		queue.start()

	reset_joypads()

	for channel in range(channels.size()):
		var rx_channel = RecieverDisplay.instance()
		add_child(rx_channel)
		rx_channel.name = "rx_channel_%d" % channel
		rx_channel.set_position(Vector2(15.0, 45.0 + (channel * 25.0)))
		rx_channel.channel = channels[channel]
		rx_channel.channel_index = channel
		rx_channel.joy_axis = assignments[channel]
		rx_channel.value = 1500
		rx_channel.inverted = false
		rx_channel.connect("joy_axis_selected", self, "joy_axis_selected")
		rx_channel.connect("joy_axis_inverted", self, "joy_axis_inverted")

	setup_rc()

	load_settings()

func reset_joypads():
	(get_node("Joystick") as OptionButton).clear()

	for i in range(10):
		var joypad = Input.get_joy_name(i)

		if joypad.length() > 0:
			get_node("Joystick").add_item(joypad)

func joy_axis_selected(channel_index, joy_index):
	assignments[channel_index] = joy_index
	setup_rc()

func joy_axis_inverted(_channel_index, _joy_index, _invert_value):
	setup_rc()

func _on_joy_connection_changed(_device_id, _connected):
	reset_joypads()

func _input(event):
	if event is InputEventJoypadMotion:
		for channel in range(channels.size()):
			var rx_channel = get_node("rx_channel_%d" % channel)

			if rx_channel.joy_axis == event.axis:
				rx_channel.value = RC.get_rc_value(RC.rc_command(channel))

func _on_Joystick_item_selected(index:int):
	joy_device = index
	RC.set_joy_device(joy_device)

func update_rc():
	$Joystick.selected = RC.get_joy_device()

	for i in range(channels.size()):
		get_node("rx_channel_%d" % i).joy_axis = RC.get_assignments()[i]
		get_node("rx_channel_%d" % i).inverted = RC.get_inverted()[i]

func setup_rc():
	RC.set_joy_device(joy_device)

	RC.set_assignments(assignments)

	RC.set_inverted([
		1 if get_node("rx_channel_%d" % 0).inverted else 0,
		1 if get_node("rx_channel_%d" % 1).inverted else 0,
		1 if get_node("rx_channel_%d" % 2).inverted else 0,
		1 if get_node("rx_channel_%d" % 3).inverted else 0,
	])

	RC.set_settings([
		1 if $Visuals/CheckBox.pressed else 0,
		1 if $Visuals/CheckBox2.pressed else 0,
		1 if $Visuals/CheckBox3.pressed else 0,
		1 if $Visuals/CheckBox4.pressed else 0,
		1 if $CheckBox5.pressed else 0,
		$Visuals/HSlider.value,
		$Visuals/FOV.value,
	])

	RC.set_rates(
		0,
		$Rates/ActualRatePanel/Roll/rc_rate_value.value,
		$Rates/ActualRatePanel/Roll/rate_value.value,
		$Rates/ActualRatePanel/Roll/expo_value.value
	)

	RC.set_rates(
		1,
		$Rates/ActualRatePanel/Pitch/rc_rate_value.value,
		$Rates/ActualRatePanel/Pitch/rate_value.value,
		$Rates/ActualRatePanel/Pitch/expo_value.value
	)

	RC.set_rates(
		2,
		$Rates/ActualRatePanel/Yaw/rc_rate_value.value,
		$Rates/ActualRatePanel/Yaw/rate_value.value,
		$Rates/ActualRatePanel/Yaw/expo_value.value
	)

func _on_Start_pressed():
	setup_rc()

	if OS.has_feature('JavaScript'):
		loader = ResourceLoader.load_interactive(main_scene)
	else:
		var _ret = queue.queue_resource(main_scene)

func _on_Default_pressed():
	pass # Replace with function body.

func _process(_delta):
	var loading = ($Loading as ProgressBar)

	if OS.has_feature('JavaScript'):
		if loader != null:
			if loading.visible != true:
				loading.visible = true
				($Start as Button).disabled = true
			
			var t = OS.get_ticks_msec()

			while OS.get_ticks_msec() < t + time_max:
				var err = loader.poll()
				if err == ERR_FILE_EOF: # Finished loading.
					var resource = loader.get_resource()
					loader = null
					var _ok = get_tree().change_scene_to(resource)
					self.queue_free()
					break
				elif err == OK:
					update_progress()
				else:
					print("Error during loading")
	else:
		if queue.is_ready(main_scene):
			var _ok = get_tree().change_scene_to(queue.get_resource(main_scene))
		else:
			if queue.get_progress(main_scene) > -1:
				loading.visible = true
				($Start as Button).disabled = true

				if queue.get_progress(main_scene) > 0:
					loading.value = queue.get_progress(main_scene)

func update_progress():
		var loading = ($Loading as ProgressBar)
		var progress = float(loader.get_stage()) / loader.get_stage_count()
		# Update your progress bar?
		loading.value = progress

func _on_CheckBox5_toggled(_button_pressed: bool):
	setup_rc()


func _on_HSlider_value_changed(value:float):
	$Visuals/HSlider/Label.text = String(value) + "°"

func _on_RichTextLabel_meta_clicked(meta):
	if OS.get_name() == "HTML5":
		JavaScript.eval("window.location.href = ' " + meta + " ';")


func _on_SaveSettings_pressed():
	if OS.is_userfs_persistent():
		save_settings()
		$Visuals/SettingsSavedLabel.visible = true
	else:
		$Visuals/SettingsSavedLabel.text = "Unable to save!"
		$Visuals/SettingsSavedLabel.visible = true

func save_settings():
	var f = File.new()
	f.open(settings_file, File.WRITE)
	f.store_var($Visuals/HSlider.value)
	f.store_var($Visuals/FOV.value)
	f.store_var($Visuals/CheckBox.pressed)
	f.store_var($Visuals/CheckBox2.pressed)
	f.store_var($Visuals/CheckBox3.pressed)
	f.store_var($Visuals/CheckBox4.pressed)
	f.store_var($Rates/RateSelectorPanel/RatesType.selected)
	f.store_var($Rates/ActualRatePanel/Roll/rc_rate_value.value)
	f.store_var($Rates/ActualRatePanel/Roll/rate_value.value)
	f.store_var($Rates/ActualRatePanel/Roll/expo_value.value)
	f.store_var($Rates/ActualRatePanel/Pitch/rc_rate_value.value)
	f.store_var($Rates/ActualRatePanel/Pitch/rate_value.value)
	f.store_var($Rates/ActualRatePanel/Pitch/expo_value.value)
	f.store_var($Rates/ActualRatePanel/Yaw/rc_rate_value.value)
	f.store_var($Rates/ActualRatePanel/Yaw/rate_value.value)
	f.store_var($Rates/ActualRatePanel/Yaw/expo_value.value)
	f.store_var($CheckBox5.pressed)
	f.store_var(RC.get_assignments())
	f.store_var(RC.get_joy_device())
	f.store_var(RC.get_inverted())

func load_settings():
	var f = File.new()
	if f.file_exists(settings_file):
		f.open(settings_file, File.READ)

		$Visuals/HSlider.value = f.get_var()
		$Visuals/FOV.value = f.get_var()
		$Visuals/CheckBox.pressed = f.get_var()
		$Visuals/CheckBox2.pressed = f.get_var()
		$Visuals/CheckBox3.pressed = f.get_var()
		$Visuals/CheckBox4.pressed = f.get_var()
		$Rates/RateSelectorPanel/RatesType.selected = f.get_var()
		$Rates/ActualRatePanel/Roll/rc_rate_value.value = f.get_var()
		$Rates/ActualRatePanel/Roll/rate_value.value = f.get_var()
		$Rates/ActualRatePanel/Roll/expo_value.value = f.get_var()
		$Rates/ActualRatePanel/Pitch/rc_rate_value.value = f.get_var()
		$Rates/ActualRatePanel/Pitch/rate_value.value = f.get_var()
		$Rates/ActualRatePanel/Pitch/expo_value.value = f.get_var()
		$Rates/ActualRatePanel/Yaw/rc_rate_value.value = f.get_var()
		$Rates/ActualRatePanel/Yaw/rate_value.value = f.get_var()
		$Rates/ActualRatePanel/Yaw/expo_value.value = f.get_var()
		$CheckBox5.pressed = f.get_var()
		RC.set_assignments(f.get_var())
		RC.set_joy_device(f.get_var())
		RC.set_inverted(f.get_var())

		update_rc()

		f.close()
