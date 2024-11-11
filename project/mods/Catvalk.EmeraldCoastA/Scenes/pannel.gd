#extends Area
#
#onready var pannel = get_parent()
#onready var pannelsfx = get_parent().get_node("AudioStreamPlayer3D")
#
#const DELTA_DAMP = 20.0
#
#var hastriggered = false
#var waittimer = 0
#var state = 0
#var Speedboost
#var PlayerAPI
#var rot
#var degrees
#var radians
#var direction
#var player
#var spd : float
#
#
#func _ready():
#	PlayerAPI = get_node_or_null("/root/BlueberryWolfiAPIs/PlayerAPI")
#	player = PlayerAPI.local_player
#	Speedboost = pannel.Speedboost
#	rot = pannel.get_rotation_degrees()
#	pass #print#(rot)
#
#func _process(delta):
#	if hastriggered == true:
#		spd = player.velocity.length();
#
#		match state:
#			0:
#				waittimer += 1
#				if waittimer == 1:
#					degrees = rot.y
#					radians = deg2rad(degrees)
#					direction = Vector3(sin(radians), 0, cos(radians))
#					player.accel = 20
#					player.velocity = direction * -Speedboost
#					pannelsfx.play()
#					if player.cam_base.rotation_degrees.y < rot.y + 40 && player.cam_base.rotation_degrees.y > rot.y - 40:
#						pass
#					else:
#						player.cam_base.rotation_degrees.y = rot.y
#					lerp(player.rotation_degrees, rot, delta * DELTA_DAMP)
#					state = 1
#					print(state)
#			1:
#				waittimer += 1
#				player.rotation_degrees = rot
#				if waittimer > 100:
#					state = 2
#					print(state)
#			2:
#				waittimer += 1
#				print(waittimer)
#				if waittimer > 300:
#					player.accel = 64
#					waittimer = 0
#					state = 0
#					hastriggered = false
#
#func _on_Area_body_entered(body):
#	if body.is_in_group("player"):
#		hastriggered = true
extends Area

# Nodes and variables
onready var pannel = get_parent()
onready var pannelsfx = pannel.get_node("AudioStreamPlayer3D")

# Constants
const DELTA_DAMP = 20.0
const INITIAL_ACCEL = 20
const RESET_ACCEL = 64
const WAIT_TIME_STEP_1 = 100
const WAIT_TIME_STEP_2 = 300
const CAMERA_ROTATION_THRESHOLD = 40

# Variables
var has_triggered = false
var wait_timer = 0
var state = 0
var speedboost
var player_api
var direction
var player
var ramp_raycast

func _ready():
	# Inicializa as variáveis e configura o RayCast apenas uma vez
	player_api = get_node_or_null("/root/BlueberryWolfiAPIs/PlayerAPI")
	player = player_api.local_player
	speedboost = pannel.Speedboost
	direction = calculate_direction()
	setup_raycast()  # Cria o RayCast para detectar a rampa apenas uma vez

func _process(delta):
	if has_triggered:
		handle_speedboost_states(delta)

func calculate_direction():
	# Calcula a direção inicial baseada na rotação do painel
	var degrees = pannel.get_rotation_degrees().y
	var radians = deg2rad(degrees)
	return Vector3(sin(radians), 0, cos(radians))

func setup_raycast():
	# Verifica se o RayCast já existe no player, caso contrário, cria-o
	if player.get_node_or_null("ramp_raycast") == null:
		ramp_raycast = RayCast.new()
		ramp_raycast.cast_to = Vector3(0, -1, 0) * 2.0  # Ajuste o comprimento conforme necessário
		ramp_raycast.enabled = true
		ramp_raycast.name = "ramp_raycast"  # Nome para identificar o RayCast
		player.add_child(ramp_raycast)

func handle_speedboost_states(delta):
	match state:
		0:
			apply_initial_boost(delta)
		1:
			wait_timer += 1
			player.rotation_degrees = pannel.get_rotation_degrees()
			ramp_raycast = player.get_node_or_null("ramp_raycast")
			if ramp_raycast.is_colliding():
				handle_ramp_movement()  # Executa a lógica de rampa enquanto em estado 1
			if wait_timer > WAIT_TIME_STEP_1:
				state = 2
		2:
			wait_timer += 1
			if wait_timer > WAIT_TIME_STEP_2:
				reset_player_state()

func apply_initial_boost(delta):
	wait_timer += 1
	if wait_timer == 1:
		player.accel = INITIAL_ACCEL
		player.velocity = direction * -speedboost
		pannelsfx.play()
		align_camera_rotation()
		lerp_rotation(delta)
		state = 1

func align_camera_rotation():
	# Alinha a rotação da câmera para garantir que siga a direção da plataforma
	var rot_y = pannel.get_rotation_degrees().y
	var cam_rot_y = player.cam_base.rotation_degrees.y
	if cam_rot_y < rot_y + CAMERA_ROTATION_THRESHOLD and cam_rot_y > rot_y - CAMERA_ROTATION_THRESHOLD:
		return
	player.cam_base.rotation_degrees.y = rot_y

func lerp_rotation(delta):
	# Suaviza a rotação do jogador
	player.rotation_degrees = lerp(player.rotation_degrees, pannel.get_rotation_degrees(), delta * DELTA_DAMP)

func handle_ramp_movement():
	var ramp_normal = ramp_raycast.get_collision_normal()
	if ramp_normal != Vector3(0, 0, 0):
		var ramp_direction = direction - ramp_normal * direction.dot(ramp_normal)  # Projeção no plano da rampa
		player.velocity = -ramp_direction * player.velocity.length()

func reset_player_state():
	player.accel = RESET_ACCEL
	wait_timer = 0
	state = 0
	has_triggered = false

func _on_Area_body_entered(body):
	if body.is_in_group("player"):
		has_triggered = true
