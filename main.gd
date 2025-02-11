extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Attempt to activate scene manager
	if %SceneManager.is_class("OpenXRFbSceneManager"):
		%SceneManager.openxr_fb_scene_data_missing.connect(_scene_data_missing)
		%SceneManager.openxr_fb_scene_capture_completed.connect(_scene_capture_complete)


func _scene_data_missing() -> void:
	print("Scene Data Missing")
	%SceneManager.request_scene_capture()

func _scene_capture_complete() -> void:
	print("Scene Capture Complete")
