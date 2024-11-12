extends Area

onready var ring = get_parent()
onready var ringsfx = get_parent().get_node("AudioStreamPlayer3D")


var PlayerAPI

var hastriggered = false

var state = 0

var respawntimer = 0

func _ready():
	PlayerAPI = get_node_or_null("/root/BlueberryWolfiAPIs/PlayerAPI")

func _process(delta):
	if hastriggered == true:
		match state:
			0:
				ringsfx.play()
				ring.visible = false
				state = 1
			1:
				respawntimer += 1
				if respawntimer > 4800:
					state = 2
			2:
				ring.visible = true
				respawntimer = 0
				state = 0
				hastriggered = false
	

func _on_Area_body_entered(body):
	if body.is_in_group("player"):
		hastriggered = true
		add_money(body)
	else :
		return 

func add_money(body):
	if body == PlayerAPI.local_player:
		PlayerData.money += 5
