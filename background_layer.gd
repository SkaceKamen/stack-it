extends CanvasLayer
class_name BackgroundLayer

@export() var backgroundTexture: TextureRect
@export() var gradients: Array[Gradient]

var target_gradient = 0
var is_transitioning = true

func colors_almost_equal(a, b, tolerance = 0.01):
  return abs(a.r - b.r) < tolerance && abs(a.g - b.g) < tolerance && abs(a.b - b.b) < tolerance;

func _process(delta):
  if is_transitioning:
    var floorIndex = floor(target_gradient)
    var colorDelta = target_gradient - floorIndex
    var startGradient = gradients[floor(target_gradient)]
    var endGradient = gradients[ceil(target_gradient)]
    var currentGradient: Gradient = backgroundTexture.texture.gradient
    var matching = 0

    for i in range(0, currentGradient.colors.size()):
      var targetColor = startGradient.colors[i].lerp(endGradient.colors[i], colorDelta)
      currentGradient.set_color(i, currentGradient.colors[i].lerp(targetColor, 1 * delta))

      if colors_almost_equal(currentGradient.colors[i], targetColor):
        matching += 1

    if matching == currentGradient.colors.size():
      is_transitioning = false
  
    backgroundTexture.texture.gradient = currentGradient;

func set_target(target):
  target_gradient = target;
  is_transitioning = true;

  while target_gradient >= gradients.size():
    target_gradient -= gradients.size()

  print("Set target to " + str(target_gradient));
