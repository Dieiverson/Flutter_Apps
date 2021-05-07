import 'dart:ui';
import 'package:rive/src/core/core.dart';
import 'package:rive/src/rive_core/animation/animation.dart';
import 'package:rive/src/rive_core/component.dart';
import 'package:rive/src/rive_core/component_dirt.dart';
import 'package:rive/src/rive_core/draw_rules.dart';
import 'package:rive/src/rive_core/draw_target.dart';
import 'package:rive/src/rive_core/drawable.dart';
import 'package:rive/src/rive_core/math/mat2d.dart';
import 'package:rive/src/rive_core/math/vec2d.dart';
import 'package:rive/src/rive_core/rive_animation_controller.dart';
import 'package:rive/src/rive_core/shapes/paint/shape_paint_mutator.dart';
import 'package:rive/src/rive_core/shapes/shape_paint_container.dart';
import 'package:rive/src/utilities/dependency_sorter.dart';
import 'package:rive/src/generated/artboard_base.dart';
export 'package:rive/src/generated/artboard_base.dart';

class Artboard extends ArtboardBase with ShapePaintContainer {
  @override
  bool get canBeOrphaned => true;
  final Path path = Path();
  List<Component> _dependencyOrder = [];
  final List<Drawable> _drawables = [];
  final List<DrawRules> _rules = [];
  List<DrawTarget> _sortedDrawRules = [];
  final Set<Component> _components = {};
  List<Drawable> get drawables => _drawables;
  final AnimationList _animations = AnimationList();
  AnimationList get animations => _animations;
  bool get hasAnimations => _animations.isNotEmpty;
  int _dirtDepth = 0;
  int _dirt = 255;
  void forEachComponent(void Function(Component) callback) =>
      _components.forEach(callback);
  @override
  Artboard get artboard => this;
  Vec2D get originWorld {
    return Vec2D.fromValues(x + width * originX, y + height * originY);
  }

  bool updateComponents() {
    bool didUpdate = false;
    if ((_dirt & ComponentDirt.drawOrder) != 0) {
      sortDrawOrder();
      _dirt &= ~ComponentDirt.drawOrder;
      didUpdate = true;
    }
    if ((_dirt & ComponentDirt.components) != 0) {
      const int maxSteps = 100;
      int step = 0;
      int count = _dependencyOrder.length;
      while ((_dirt & ComponentDirt.components) != 0 && step < maxSteps) {
        _dirt &= ~ComponentDirt.components;
        for (int i = 0; i < count; i++) {
          Component component = _dependencyOrder[i];
          _dirtDepth = i;
          int d = component.dirt;
          if (d == 0) {
            continue;
          }
          component.dirt = 0;
          component.update(d);
          if (_dirtDepth < i) {
            break;
          }
        }
        step++;
      }
      return true;
    }
    return didUpdate;
  }

  bool advance(double elapsedSeconds) {
    bool didUpdate = false;
    for (final controller in _animationControllers) {
      if (controller.isActive) {
        controller.apply(context, elapsedSeconds);
        didUpdate = true;
      }
    }
    return updateComponents() || didUpdate;
  }

  @override
  void heightChanged(double from, double to) {
    addDirt(ComponentDirt.worldTransform);
    invalidateStrokeEffects();
  }

  void onComponentDirty(Component component) {
    if ((dirt & ComponentDirt.components) == 0) {
      context.markNeedsAdvance();
      _dirt |= ComponentDirt.components;
    }
    if (component.graphOrder < _dirtDepth) {
      _dirtDepth = component.graphOrder;
    }
  }

  @override
  bool resolveArtboard() => true;
  void sortDependencies() {
    var optimistic = DependencySorter<Component>();
    var order = optimistic.sort(this);
    if (order.isEmpty) {
      var robust = TarjansDependencySorter<Component>();
      order = robust.sort(this);
    }
    _dependencyOrder = order;
    for (final component in _dependencyOrder) {
      component.graphOrder = graphOrder++;
    }
    _dirt |= ComponentDirt.components;
  }

  @override
  void update(int dirt) {
    if (dirt & ComponentDirt.worldTransform != 0) {
      var rect =
          Rect.fromLTWH(width * -originX, height * -originY, width, height);
      path.reset();
      path.addRect(rect);
    }
  }

  @override
  void widthChanged(double from, double to) {
    addDirt(ComponentDirt.worldTransform);
    invalidateStrokeEffects();
  }

  @override
  void xChanged(double from, double to) {
    addDirt(ComponentDirt.worldTransform);
  }

  @override
  void yChanged(double from, double to) {
    addDirt(ComponentDirt.worldTransform);
  }

  Vec2D renderTranslation(Vec2D worldTranslation) {
    final wt = originWorld;
    return Vec2D.add(Vec2D(), worldTranslation, wt);
  }

  void addComponent(Component component) {
    if (!_components.add(component)) {
      return;
    }
  }

  void removeComponent(Component component) {
    _components.remove(component);
  }

  void markDrawOrderDirty() {
    if ((dirt & ComponentDirt.drawOrder) == 0) {
      context.markNeedsAdvance();
      _dirt |= ComponentDirt.drawOrder;
    }
  }

  void draw(Canvas canvas) {
    canvas.save();
    canvas.clipRect(Rect.fromLTWH(0, 0, width, height));
    canvas.translate(width * originX, height * originY);
    for (final fill in fills) {
      fill.draw(canvas, path);
    }
    for (var drawable = _firstDrawable;
        drawable != null;
        drawable = drawable.prev) {
      if (drawable.isHidden) {
        continue;
      }
      drawable.draw(canvas);
    }
    canvas.restore();
  }

  @override
  Mat2D get worldTransform => Mat2D();
  @override
  void originXChanged(double from, double to) {
    addDirt(ComponentDirt.worldTransform);
  }

  @override
  void originYChanged(double from, double to) {
    addDirt(ComponentDirt.worldTransform);
  }

  bool internalAddAnimation(Animation animation) {
    if (_animations.contains(animation)) {
      return false;
    }
    _animations.add(animation);
    return true;
  }

  bool internalRemoveAnimation(Animation animation) {
    bool removed = _animations.remove(animation);
    return removed;
  }

  final Set<RiveAnimationController> _animationControllers = {};
  bool addController(RiveAnimationController controller) {
    if (_animationControllers.contains(controller) ||
        !controller.init(context)) {
      return false;
    }
    controller.isActiveChanged.addListener(_onControllerPlayingChanged);
    _animationControllers.add(controller);
    if (controller.isActive) {
      context.markNeedsAdvance();
    }
    return true;
  }

  bool removeController(RiveAnimationController controller) {
    if (_animationControllers.remove(controller)) {
      controller.isActiveChanged.removeListener(_onControllerPlayingChanged);
      controller.dispose();
      return true;
    }
    return false;
  }

  void _onControllerPlayingChanged() => context.markNeedsAdvance();
  @override
  void onFillsChanged() {}
  @override
  void onPaintMutatorChanged(ShapePaintMutator mutator) {}
  @override
  void onStrokesChanged() {}
  @override
  Vec2D get worldTranslation => Vec2D();
  Drawable? _firstDrawable;
  void computeDrawOrder() {
    _drawables.clear();
    _rules.clear();
    buildDrawOrder(_drawables, null, _rules);
    var root = DrawTarget();
    for (final nodeRules in _rules) {
      for (final target in nodeRules.targets) {
        target.dependents.clear();
      }
    }
    for (final nodeRules in _rules) {
      for (final target in nodeRules.targets) {
        root.dependents.add(target);
        var dependentRules = target.drawable?.flattenedDrawRules;
        if (dependentRules != null) {
          for (final dependentRule in dependentRules.targets) {
            dependentRule.dependents.add(target);
          }
        }
      }
    }
    var sorter = DependencySorter<Component>();
    _sortedDrawRules = sorter.sort(root).cast<DrawTarget>().skip(1).toList();
    sortDrawOrder();
  }

  void sortDrawOrder() {
    for (final rule in _sortedDrawRules) {
      rule.first = rule.last = null;
    }
    _firstDrawable = null;
    Drawable? lastDrawable;
    for (final drawable in _drawables) {
      var rules = drawable.flattenedDrawRules;
      var target = rules?.activeTarget;
      if (target != null) {
        if (target.first == null) {
          target.first = target.last = drawable;
          drawable.prev = drawable.next = null;
        } else {
          target.last?.next = drawable;
          drawable.prev = target.last;
          target.last = drawable;
          drawable.next = null;
        }
      } else {
        drawable.prev = lastDrawable;
        drawable.next = null;
        if (lastDrawable == null) {
          lastDrawable = _firstDrawable = drawable;
        } else {
          lastDrawable.next = drawable;
          lastDrawable = drawable;
        }
      }
    }
    for (final rule in _sortedDrawRules) {
      if (rule.first == null) {
        continue;
      }
      switch (rule.placement) {
        case DrawTargetPlacement.before:
          if (rule.drawable?.prev != null) {
            rule.drawable!.prev?.next = rule.first;
            rule.first?.prev = rule.drawable!.prev;
          }
          if (rule.drawable == _firstDrawable) {
            _firstDrawable = rule.first;
          }
          rule.drawable?.prev = rule.last;
          rule.last?.next = rule.drawable;
          break;
        case DrawTargetPlacement.after:
          if (rule.drawable?.next != null) {
            rule.drawable!.next!.prev = rule.last;
            rule.last?.next = rule.drawable?.next;
          }
          if (rule.drawable == lastDrawable) {
            lastDrawable = rule.last;
          }
          rule.drawable?.next = rule.first;
          rule.first?.prev = rule.drawable;
          break;
      }
    }
    _firstDrawable = lastDrawable;
  }
}
