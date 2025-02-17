extends CanvasLayer
class_name BackgroundLayer

@export() var backgroundTexture: TextureRect
@export() var gradients: Array[Gradient]

var target_gradient = 0
var is_transitioning = true

func colors_almost_equal(a, b, tolerance = 0.01):
  return abs(a.R - b.R) < tolerance && abs(a.G - b.G) < tolerance && abs(a.B - b.B) < tolerance;

func _process(delta):
  if is_transitioning:
    var floorIndex = floor(target_gradient)
    var colorDelta = target_gradient - floorIndex
    var startGradient = gradients[floor(target_gradient)]
    var endGradient = gradients[ceil(target_gradient)]
    var currentGradient: Gradient = backgroundTexture.texture.gradient
    var matching = 0

    for i in range(0, currentGradient.colors.size()):
      var targetColor = startGradient.Colors[i].Lerp(endGradient.Colors[i], colorDelta)
      currentGradient.set_color(i, currentGradient.colors[i].lerp(targetColor, 1 * delta))

      if colors_almost_equal(currentGradient.Colors[i], targetColor):
        matching += 1

    if matching == currentGradient.Colors.Length:
      is_transitioning = false
  
    backgroundTexture.texture.gradient = currentGradient;

func set_target(target):
  target_gradient = target % (gradients.size() - 1);
  is_transitioning = true;

  print("Set target to " + target_gradient);
