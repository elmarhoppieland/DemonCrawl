@tool
extends Frame
class_name BeyondArtifactDisplay

# ==============================================================================
@export var stage: StageFile = null :
	set(value):
		stage = value
		
		if not is_node_ready():
			await ready
		
		if not value:
			_artifact_texture.texture = null
			_tooltip_grabber.text = ""
			_tooltip_grabber.subtext = ""
			return
		
		_artifact_texture.texture = value.artifact_texture
		
		_tooltip_grabber.text = tr(value.artifact_name).to_upper()
		_tooltip_grabber.text_color = Artifact.TITLE_COLOR
		_tooltip_grabber.subtext = tr("object.artifact.description").format({ "stage": tr(value.name) })
@export var count := 0 :
	set(value):
		count = value
		
		if not is_node_ready():
			await ready
		
		if count < 1000:
			_count_label.text = str(value)
		else:
			_count_label.text = str(value / 1000) + "K"
# ==============================================================================
@onready var _artifact_texture: TextureRect = %ArtifactTexture
@onready var _count_label: Label = %CountLabel
@onready var _tooltip_grabber: TooltipGrabber = %TooltipGrabber
# ==============================================================================
