extends Area

onready var sfx = get_node("AudioStreamPlayer3D")
onready var checkpoint = $checkpoint/AnimationPlayer

signal checkp_area_entered

export var id : int

var PlayerAPI
var selected

func _ready():
	PlayerAPI = get_node_or_null("/root/BlueberryWolfiAPIs/PlayerAPI")
	.get_parent().connect("update_check", self,"_update_check")

func _update_check():
		if .get_parent().Selected == id:
			PlayerAPI.local_player.last_valid_pos = self.global_translation
			sfx.play()
			checkpoint.play_backwards("close")
		else:
			checkpoint.play("close")


func _on_Checkpoint1_body_entered(body):
	if body.is_in_group("player") &&  body == PlayerAPI.local_player && id != .get_parent().Selected:
		.get_parent().Selected = id
		emit_signal("checkp_area_entered")
