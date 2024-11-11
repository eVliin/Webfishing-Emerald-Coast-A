extends Node
#
## Constantes e variáveis
#export var SPEED_THRESHOLD = 10.0  # Velocidade mínima para andar em superfícies verticais e teto
#const GRAVITY = Vector3(0, -32.0, 0)  # Gravidade padrão
#var custom_gravity = GRAVITY
#var is_wall_walking = false  # Define se o player está andando na parede/teto
#
export(float) var raycast_length = 2.0
onready var raycast
## Referência ao player
var player_api
var player
#var velocity = Vector3.ZERO
#
func _ready():
	raycast = .get_parent().get_node("ramp_raycast")
	# Configura a referência ao player ao instanciar
	player_api = get_node_or_null("/root/BlueberryWolfiAPIs/PlayerAPI")
	player = player_api.local_player
#	if player:
#		velocity = player.velocity  # Usa a velocidade inicial do player
#		print(velocity)
#
#func _physics_process(delta):
#	if not player:
#		return
#
#	# Atualize a velocidade conforme a velocidade atual do player
#	velocity = player.velocity  # Obtém a velocidade atual do player
#
#	# Detectar colisões com chão, parede ou teto e verificar velocidade
#	if is_on_wall_left() and velocity.length() >= SPEED_THRESHOLD:
#		start_wall_walk(Vector3.LEFT)
#	elif is_on_wall_right() and velocity.length() >= SPEED_THRESHOLD:
#		start_wall_walk(Vector3.RIGHT)
##	elif is_on_ceiling() and velocity.length() >= SPEED_THRESHOLD:
##		start_ceiling_walk()
#	elif is_on_floor():
#		stop_wall_walk()
#
#	# Se o player estiver em modo "wall walk", aplicar gravidade customizada
#	if is_wall_walking:
#		apply_wall_walk_gravity(delta)
#	else:
#		apply_default_gravity(delta)
#
#func is_on_wall_left() -> bool:
#	# Verifica se há colisão à esquerda
#	var collision = player.get_last_slide_collision()
#	return collision and collision.normal.dot(Vector3.LEFT) > 0.9
#
#func is_on_wall_right() -> bool:
#	# Verifica se há colisão à direita
#	var collision = player.get_last_slide_collision()
#	return collision and collision.normal.dot(Vector3.RIGHT) > 0.9
#
#func is_on_ceiling() -> bool:
#	# Verifica se há colisão com o teto
#	var collision = player.get_last_slide_collision()
#	return collision and collision.normal.dot(Vector3.UP) > 0.9
#
#func is_on_floor() -> bool:
#	# Verifica se há colisão com o chão
#	var collision = player.get_last_slide_collision()
#	return collision and collision.normal.dot(Vector3.DOWN) > 0.9
#
#func start_wall_walk(direction: Vector3):
#	is_wall_walking = true
#	custom_gravity = direction * GRAVITY.length()
#	print("Iniciando wall walk")
#
#func start_ceiling_walk():
#	is_wall_walking = true
#	custom_gravity = Vector3.UP * GRAVITY.length()
#
#func stop_wall_walk():
#	is_wall_walking = false
#	custom_gravity = GRAVITY
#
#func apply_wall_walk_gravity(delta):
#	# Aplica a gravidade na direção customizada
#	velocity += custom_gravity * delta
#	player.move_and_slide(velocity, custom_gravity.normalized())
#
#func apply_default_gravity(delta):
#	# Aplica a gravidade padrão para o chão
#	velocity += GRAVITY * delta
#	player.move_and_slide(velocity, Vector3.UP)



func _physics_process(delta):
	print(raycast)
	if raycast.is_colliding():
		var collision_normal = raycast.get_collision_normal()
		_align_with_normal(collision_normal)

func _align_with_normal(normal: Vector3):
	var up_dir = normal.normalized()
	var current_transform = player.global_transform
	current_transform.basis = Basis(up_dir).orthonormalized()
	player.global_transform = current_transform
