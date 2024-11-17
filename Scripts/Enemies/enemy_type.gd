extends Resource

class_name EnemyType

@export var speed: float = 2000
@export var patrol_wait_time = 1.0
@export var max_health = 30
@export var chase_distance: float = 200.0

@export var sprite_frames: SpriteFrames
@export var collision_shape: CapsuleShape2D
@export var attack_collision: RectangleShape2D
@export var agro_collision: CircleShape2D
