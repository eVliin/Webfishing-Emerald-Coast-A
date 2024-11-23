extends Area

onready var platform = get_parent()
onready var platformsfx = get_parent().get_node("AudioStreamPlayer3D")
onready var platformsfx2 = get_parent().get_node("AudioStreamPlayer3D2")

var hastriggered = false
var grav = 0.0
var rot = 0.0
var waittimer = 0
var falltimer = 0
var state = 0
var origin_y = 0.0

# Armazena a velocidade do player no momento da ativação
var player_velocity = 0.0

# Ajustes para um timing mais rápido
const INITIAL_WAIT_TIME = 10  # Tempo de espera reduzido antes de começar a queda
const FALL_ACCELERATION = 0.5  # Aceleração maior para a queda
const ROTATION_SPEED = 0.1  # Velocidade de rotação da plataforma enquanto cai

func _ready():
	origin_y = platform.translation.y

func _process(delta):
	if hastriggered:
		match state:
			0:
				# Espera um curto tempo para começar a queda
				waittimer += 1
				if waittimer >= INITIAL_WAIT_TIME:  # Espera apenas um curto período
					state = 1
					platformsfx.play()  # Som do início da queda
			1:
				# Aguarda um pouco antes de começar a queda real
				waittimer += 1
				if waittimer >= 30:  # Apenas um pequeno atraso após o início
					state = 2
					platformsfx.stop()
					platformsfx2.play()  # Som do movimento da plataforma
			2:
				# Inicia a queda
				falltimer += 1
				# A gravidade agora acelera mais rapidamente
				grav -= FALL_ACCELERATION + player_velocity * 0.1  # A gravidade depende da velocidade do player
				rot -= ROTATION_SPEED  # Adiciona rotação contínua
				platform.translation.y += grav * delta
				platform.rotate_z(rot * delta)  # Aplica rotação ao redor do eixo Z
				if falltimer > 300:
					state = 3  # Finaliza a queda após um tempo curto
			3:
				# Reseta os valores após a queda completa
				waittimer = 0
				falltimer = 0
				grav = 0.0
				rot = 0.0
				platform.translation.y = origin_y  # Volta à posição original
				platform.set_rotation(Vector3(0.0, 0.0, 0.0))  # Reseta rotação
				hastriggered = false
				state = 0

# Quando o player entra na área da plataforma, inicia o processo
func _on_Area_body_entered(body):
	if body.is_in_group("player"):
		hastriggered = true
		# Captura 
