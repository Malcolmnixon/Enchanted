extends Node


## Current XR interface
var xr_interface : XRInterface

## XR active flag
var xr_active : bool = false

# Is a WebXR is_session_supported query running
var _webxr_session_query : bool = false


# Handle auto-initialization when ready
func _ready() -> void:
	if !Engine.is_editor_hint():
		start_xr()


## Start the XR interface
func start_xr() -> bool:
	# Skip if already active
	if xr_active:
		return true

	# Check for OpenXR interface
	xr_interface = XRServer.find_interface('OpenXR')
	if xr_interface:
		return _setup_for_openxr()

	# Check for WebXR interface
	xr_interface = XRServer.find_interface('WebXR')
	if xr_interface:
		return _setup_for_webxr()

	# No XR interface
	xr_interface = null
	print("No XR interface detected")
	return false


## End the XR experience
func end_xr() -> void:
	# For WebXR drop the interactive experience and go back to the web page
	if xr_interface is WebXRInterface:
		# Uninitialize the WebXR interface
		xr_interface.uninitialize()
		return

	# Terminate the application
	get_tree().quit()


# Perform OpenXR setup
func _setup_for_openxr() -> bool:
	print("OpenXR: Configuring interface")

	# Initialize the OpenXR interface
	if not xr_interface.is_initialized():
		print("OpenXR: Initializing interface")
		if not xr_interface.initialize():
			push_error("OpenXR: Failed to initialize")
			return false

	# Connect the OpenXR events
	xr_interface.connect("session_begun", _on_openxr_session_begun)
	xr_interface.connect("session_visible", _on_openxr_visible_state)
	xr_interface.connect("session_focussed", _on_openxr_focused_state)

	# Check for passthrough
	if xr_interface.is_passthrough_supported():
		xr_interface.start_passthrough()

	# Disable vsync
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)

	# Switch the viewport to XR
	get_viewport().transparent_bg = true
	get_viewport().use_xr = true

	# Report success
	return true


# Handle OpenXR session ready
func _on_openxr_session_begun() -> void:
	print("OpenXR: Session begun")


# Handle OpenXR visible state
func _on_openxr_visible_state() -> void:
	# Report the XR ending
	if xr_active:
		print("OpenXR: XR ended (visible_state)")
		xr_active = false


# Handle OpenXR focused state
func _on_openxr_focused_state() -> void:
	# Report the XR starting
	if not xr_active:
		print("OpenXR: XR started (focused_state)")
		xr_active = true


# Perform WebXR setup
func _setup_for_webxr() -> bool:
	print("WebXR: Configuring interface")

	# Connect the WebXR events
	xr_interface.connect("session_supported", _on_webxr_session_supported)
	xr_interface.connect("session_started", _on_webxr_session_started)
	xr_interface.connect("session_ended", _on_webxr_session_ended)
	xr_interface.connect("session_failed", _on_webxr_session_failed)

	# If the viewport is already in XR mode then we are done.
	if get_viewport().use_xr:
		return true

	# This returns immediately - our _webxr_session_supported() method
	# (which we connected to the "session_supported" signal above) will
	# be called sometime later to let us know if it's supported or not.
	_webxr_session_query = true
	xr_interface.is_session_supported('immersive-ar')

	# Report success
	return true


# Handle WebXR session supported check
func _on_webxr_session_supported(session_mode: String, supported: bool) -> void:
	# Skip if not running session-query
	if not _webxr_session_query:
		return

	# Clear the query flag
	_webxr_session_query = false

	# Report if not supported
	if not supported:
		OS.alert("Your web browser doesn't support " + session_mode + ". Sorry!")
		return

	# WebXR supported - show canvas on web browser to enter WebVR
	$EnterWebXR.visible = true


# Called when the WebXR session has started successfully
func _on_webxr_session_started() -> void:
	print("WebXR: Session started")

	# Hide the canvas and switch the viewport to XR
	$EnterWebXR.visible = false
	get_viewport().transparent_bg = true
	get_viewport().use_xr = true

	# Report the XR starting
	xr_active = true


# Called when the user ends the immersive VR session
func _on_webxr_session_ended() -> void:
	print("WebXR: Session ended")

	# Show the canvas and switch the viewport to non-XR
	$EnterWebXR.visible = true
	get_viewport().transparent_bg = false
	get_viewport().use_xr = false

	# Report the XR ending
	xr_active = false


# Called when the immersive VR session fails to start
func _on_webxr_session_failed(message: String) -> void:
	OS.alert("Unable to enter VR: " + message)
	$EnterWebXR.visible = true


# Handle the Enter VR button on the WebXR browser
func _on_enter_webxr_button_pressed() -> void:
	# Configure the WebXR interface
	xr_interface.session_mode = 'immersive-ar'
	xr_interface.requested_reference_space_types = 'bounded-floor, local-floor, local'
	xr_interface.required_features = 'local-floor, hand-tracking'
	xr_interface.optional_features = 'bounded-floor'

	# Initialize the interface. This should trigger either _on_webxr_session_started
	# or _on_webxr_session_failed
	if not xr_interface.initialize():
		OS.alert("Failed to initialize WebXR")
