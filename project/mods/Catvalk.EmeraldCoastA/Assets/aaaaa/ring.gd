extends Area

# Constantes
const RESPAWN_TIME = 4800

# Referências onready
onready var ring = get_parent()
onready var ringsfx = ring.get_node("AudioStreamPlayer3D")

# Variáveis
var PlayerAPI
var has_triggered = false
var in_game = false
var state = 0
var respawn_timer = 0

func _ready():
	PlayerAPI = get_node_or_null("/root/BlueberryWolfiAPIs/PlayerAPI")
	if PlayerAPI:
		PlayerAPI.connect("_ingame", self, "_player_ready")

func _player_ready():
	in_game = true

func _physics_process(delta):
	if not in_game or not has_triggered:
		return

	match state:
		0:
			ringsfx.play()
			ring.visible = false
			state = 1
		1:
			respawn_timer += 1
			if respawn_timer >= RESPAWN_TIME:
				state = 2
		2:
			ring.visible = true
			respawn_timer = 0
			state = 0
			has_triggered = false

func _on_Area_body_entered(body):
	if body.is_in_group("player"):
		has_triggered = true
		add_money(body)

func add_money(body):
	if body == PlayerAPI.local_player:
		PlayerData.money += 5
