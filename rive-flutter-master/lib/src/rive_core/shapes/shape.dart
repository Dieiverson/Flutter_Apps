import 'dart:ui' as ui;
import 'package:rive/src/rive_core/component_dirt.dart';
import 'package:rive/src/rive_core/shapes/paint/linear_gradient.dart' as core;
import 'package:rive/src/rive_core/shapes/paint/shape_paint_mutator.dart';
import 'package:rive/src/rive_core/shapes/paint/stroke.dart';
import 'package:rive/src/rive_core/shapes/path.dart';
import 'package:rive/src/rive_core/shapes/path_composer.dart';
import 'package:rive/src/rive_core/shapes/shape_paint_container.dart';
import 'package:rive/src/generated/shapes/shape_base.dart';
import 'package:collection/collection.dart';
export 'package:rive/src/generated/shapes/shape_base.dart';

class Shape extends ShapeBase with ShapePaintContainer {
  final Set<Path> paths = {};
  bool _wantWorldPath = false;
  bool _wantLocalPath = false;
  bool get wantWorldPath => _wantWorldPath;
  bool get wantLocalPath => _wantLocalPath;
  bool _fillInWorld = false;
  bool get fillInWorld => _fillInWorld;
  late PathComposer pathComposer;
  Shape() {
    pathComposer = PathComposer(this);
  }
  ui.Path get fillPath => pathComposer.fillPath;
  bool addPath(Path path) {
    paintChanged();
    return paths.add(path);
  }

  void _markComposerDirty() {
    pathComposer.addDirt(ComponentDirt.path, recurse: true);
    invalidateStrokeEffects();
  }

  void pathChanged(Path path) => _markComposerDirty();
  void paintChanged() {
    addDirt(ComponentDirt.path);
    _markBlendModeDirty();
    _markRenderOpacityDirty();
    for (final d in dependents) {
      d.addDirt(ComponentDirt.worldTransform);
    }
    _markComposerDirty();
  }

  @override
  bool addStroke(Stroke stroke) {
    paintChanged();
    return super.addStroke(stroke);
  }

  @override
  bool removeStroke(Stroke stroke) {
    paintChanged();
    return super.removeStroke(stroke);
  }

  @override
  void update(int dirt) {
    super.update(dirt);
    if (dirt & ComponentDirt.blendMode != 0) {
      for (final fill in fills) {
        fill.blendMode = blendMode;
      }
      for (final stroke in strokes) {
        stroke.blendMode = blendMode;
      }
    }
    if (dirt & ComponentDirt.worldTransform != 0) {
      for (final fill in fills) {
        fill.renderOpacity = renderOpacity;
      }
      for (final stroke in strokes) {
        stroke.renderOpacity = renderOpacity;
      }
    }
    if (dirt & ComponentDirt.path != 0) {
      _wantWorldPath = false;
      _wantLocalPath = false;
      for (final stroke in strokes) {
        if (stroke.transformAffectsStroke) {
          _wantLocalPath = true;
        } else {
          _wantWorldPath = true;
        }
      }
      _fillInWorld = _wantWorldPath || !_wantLocalPath;
      var mustFillLocal = fills.firstWhereOrNull(
              (fill) => fill.paintMutator is core.LinearGradient) !=
          null;
      if (mustFillLocal) {
        _fillInWorld = false;
        _wantLocalPath = true;
      }
      for (final fill in fills) {
        var mutator = fill.paintMutator;
        if (mutator is core.LinearGradient) {
          mutator.paintsInWorldSpace = _fillInWorld;
        }
      }
      for (final stroke in strokes) {
        var mutator = stroke.paintMutator;
        if (mutator is core.LinearGradient) {
          mutator.paintsInWorldSpace = !stroke.transformAffectsStroke;
        }
      }
    }
  }

  bool removePath(Path path) {
    paintChanged();
    return paths.remove(path);
  }

  @override
  void blendModeValueChanged(int from, int to) => _markBlendModeDirty();
  @override
  void draw(ui.Canvas canvas) {
    bool clipped = clip(canvas);
    var path = pathComposer.fillPath;
    if (!_fillInWorld) {
      canvas.save();
      canvas.transform(worldTransform.mat4);
    }
    for (final fill in fills) {
      fill.draw(canvas, path);
    }
    if (!_fillInWorld) {
      canvas.restore();
    }
    for (final stroke in strokes) {
      var transformAffectsStroke = stroke.transformAffectsStroke;
      var path = transformAffectsStroke
          ? pathComposer.localPath
          : pathComposer.worldPath;
      if (transformAffectsStroke) {
        canvas.save();
        canvas.transform(worldTransform.mat4);
        stroke.draw(canvas, path);
        canvas.restore();
      } else {
        stroke.draw(canvas, path);
      }
    }
    if (clipped) {
      canvas.restore();
    }
  }

  void _markBlendModeDirty() => addDirt(ComponentDirt.blendMode);
  void _markRenderOpacityDirty() => addDirt(ComponentDirt.worldTransform);
  @override
  void onPaintMutatorChanged(ShapePaintMutator mutator) {
    paintChanged();
  }

  @override
  void onStrokesChanged() => paintChanged();
  @override
  void onFillsChanged() => paintChanged();
  @override
  void buildDependencies() {
    super.buildDependencies();
    pathComposer.buildDependencies();
  }
}
