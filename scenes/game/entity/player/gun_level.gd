extends Resource

# This is a custom resource used by the gun levels to have unique properties.

# The class name property is used to identify the custom resource.
# The A_ prefix makes it easier to find it in the long list of resources.
class_name A_GunLevel

# You can customize the basic damage, fire rate and bullet speed.
export var damage := 10
export var fire_rate := 0.2
export var bullet_speed := 600.0
# Each bullet level can use a seperate bullet scene file.
export var bullet_scene: PackedScene
# The gun can be alternating in firing.
export var alternating := true
# The gun can request an index and side value used by the bullet scene.
export var give_index := false
export var give_side := false
# The gun can contain an audio clip and customized volume to use.
export var audio_stream : AudioStream
export var audio_volume := 0.0
