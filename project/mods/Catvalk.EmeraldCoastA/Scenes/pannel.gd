extends Area

# Nodes e variáveis
onready var pannel = get_parent()
onready var pannelsfx = pannel.get_node("AudioStreamPlayer3D")

# Constantes
const DELTA_DAMP = 20.0
const INITIAL_ACCEL = 20          # Aceleração inicial do dash
const RESET_ACCEL = 64            # Aceleração padrão após o dash
export var WAIT_TIME_STEP_2 = 300     # Tempo de espera para o segundo passo do dash
var half_time
var WAIT_TIME_STEP_1     # Tempo de espera para o primeiro passo do dash
const CAMERA_ROTATION_THRESHOLD = 40  # Limite para alinhar a rotação da câmera
const SPEED_THRESHOLD = 10.0         # Limite de velocidade mínima para o dash

# Variáveis
var raycast
var has_triggered = false      # Verifica se o dash foi ativado
var wait_timer = 0             # Timer para controle de tempo entre estados
var state = 0                  # Estado atual do dash (0: esperando, 1: aplicando, 2: resetando)
var speedboost                 # Intensidade do boost de velocidade
var player_api                 # Referência à API do jogador
var local_player               # Referência ao jogador local
var direction                  # Direção do dash
var deaths                     # Contador de mortes do jogador

# Função chamada quando o nó é inicializado
func _ready():
	# Conecta a API do jogador e inicializa as variáveis
	player_api = get_node_or_null("/root/BlueberryWolfiAPIs/PlayerAPI")
	half_time = WAIT_TIME_STEP_2 % 2
	WAIT_TIME_STEP_1 = WAIT_TIME_STEP_2 - half_time 
	if player_api:
		player_api.connect("_ingame", self, "_player_ready")
		speedboost = pannel.Speedboost
		direction = calculate_direction()

# Função chamada quando o jogador está pronto (iniciado no jogo)
func _player_ready():
	local_player = player_api.local_player
	deaths = local_player.death_counter
	raycast = local_player.get_node("safe_check")

# Função chamada a cada frame
func _process(delta):
	if not has_triggered:
		return
	handle_speedboost_states(delta)

# Calcula a direção do dash com base na rotação do painel
func calculate_direction() -> Vector3:
	var degrees = pannel.get_rotation_degrees().y
	var radians = deg2rad(degrees)
	return Vector3(sin(radians), 0, cos(radians))

# Função para controlar os estados do dash
func handle_speedboost_states(delta):
	# Reseta o movimento do jogador se houve uma morte recente
	if deaths == local_player.death_counter - 1:
		local_player.velocity = Vector3.ZERO
		deaths = local_player.death_counter
	else:
		deaths = local_player.death_counter

	# Switch case baseado no estado atual do dash
	match state:
		0:
			apply_initial_boost(delta)
		1:
			wait_timer += 1
			local_player.rotation_degrees = pannel.get_rotation_degrees()
			local_player.diving = false
			if wait_timer > WAIT_TIME_STEP_1:
				state = 2
		2:
			wait_timer += 1
			if wait_timer > WAIT_TIME_STEP_2:
				reset_player_state(delta)

# Aplica o impulso inicial do dash
func apply_initial_boost(delta):
	wait_timer += 1
	if wait_timer == 1:
		# Acelera o jogador na direção do painel
		local_player.accel = INITIAL_ACCEL
		local_player.velocity = direction * -speedboost
		align_camera_rotation()  # Alinha a rotação da câmera
		lerp_rotation(delta)     # Suaviza a rotação do jogador
		pannelsfx.play()         # Reproduz o som do painel
		local_player.animation_data["sprinting"] = true  # Ativa animação de sprint
		state = 1

# Alinha a rotação da câmera com a direção do painel
func align_camera_rotation():
	var rot_y = pannel.get_rotation_degrees().y
	var cam_rot_y = local_player.cam_base.rotation_degrees.y
	# Alinha a rotação da câmera se necessário
	if abs(cam_rot_y - rot_y) > CAMERA_ROTATION_THRESHOLD:
		local_player.cam_base.rotation_degrees.y = rot_y

# Suaviza a rotação do jogador para alinhar com o painel
func lerp_rotation(delta):
	local_player.rotation_degrees = lerp(local_player.rotation_degrees, pannel.get_rotation_degrees(), delta * DELTA_DAMP)

# Reseta o estado do jogador após o dash
func reset_player_state(delta):
	local_player.animation_data["sprinting"] = false
	# Suaviza a aceleração de volta para o valor padrão
	local_player.accel = lerp(local_player.accel, RESET_ACCEL, delta * DELTA_DAMP)
	wait_timer = 0
	state = 0
	has_triggered = false

# Função chamada quando um corpo entra na área de colisão
func _on_Area_body_entered(body):
	if body.is_in_group("player") and body == local_player:
		has_triggered = true
		pannelsfx.play()  # Toca o som do painel

# Verifica se o jogador está em uma rampa
func is_on_ramp() -> bool:
	# A rampa é identificada por sua normal (inclinação da superfície)
	return raycast.is_colliding() and raycast.get_collision_normal().y < 0.5

# Ajusta a velocidade do jogador caso ele esteja em uma rampa
func handle_dash_on_ramp():
	# Verifica se o jogador está em uma rampa
	if is_on_ramp():
		var collision_normal = raycast.get_collision_normal()
		# Ajusta a direção do dash
