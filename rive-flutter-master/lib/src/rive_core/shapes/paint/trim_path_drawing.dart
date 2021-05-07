import 'dart:math';
import 'dart:ui';

class _FirstExtractedPath {
  final Path path;
  double length;
  final PathMetric metric;
  _FirstExtractedPath(this.path, this.metric, this.length);
}

_FirstExtractedPath? _appendPathSegmentSequential(
    Iterable<PathMetric> metrics, Path result, double start, double stop,
    {_FirstExtractedPath? first}) {
  double nextOffset = 0;
  double offset = 0;
  for (final metric in metrics) {
    nextOffset += metric.length;
    if (start < nextOffset) {
      var st = max(0.0, start - offset);
      var et = min(metric.length, stop - offset);
      var extractLength = et - st;
      Path extracted = metric.extractPath(st, et);
      if (first == null) {
        // ignore: parameter_assignments
        first = _FirstExtractedPath(extracted, metric, extractLength);
      } else if (first.metric == metric) {
        first.length += extractLength;
        if (metric.isClosed) {
          first.path.extendWithPath(extracted, Offset.zero);
        } else {
          result.addPath(extracted, Offset.zero);
        }
      } else {
        if (metric.isClosed && extractLength == metric.length) {
          extracted.close();
        }
        result.addPath(extracted, Offset.zero);
      }
      if (stop < nextOffset) {
        break;
      }
    }
    offset = nextOffset;
  }
  return first;
}

void _appendPathSegmentSync(
    PathMetric metric, Path to, double start, double stop,
    {bool startWithMoveTo = true}) {
  double nextOffset = metric.length;
  if (start < nextOffset) {
    Path extracted = metric.extractPath(start, stop);
    if (startWithMoveTo) {
      to.addPath(extracted, Offset.zero);
    } else {
      to.extendWithPath(extracted, Offset.zero);
    }
  }
}

void _trimPathSequential(
    Path path, Path result, double startT, double stopT, bool complement) {
  var metrics = path.computeMetrics().toList(growable: false);
  double totalLength = 0.0;
  for (final metric in metrics) {
    totalLength += metric.length;
  }
  double trimStart = totalLength * startT;
  double trimStop = totalLength * stopT;
  _FirstExtractedPath? first;
  if (complement) {
    if (trimStop < totalLength) {
      first =
          _appendPathSegmentSequential(metrics, result, trimStop, totalLength);
    }
    if (trimStart > 0.0) {
      _appendPathSegmentSequential(metrics, result, 0.0, trimStart,
          first: first);
    }
  } else if (trimStart < trimStop) {
    first = _appendPathSegmentSequential(metrics, result, trimStart, trimStop);
  }
  if (first != null) {
    if (first.length == first.metric.length) {
      first.path.close();
    }
    result.addPath(first.path, Offset.zero);
  }
}

void _trimPathSync(
    Path path, Path result, double startT, double stopT, bool complement) {
  final metrics = path.computeMetrics().toList(growable: false);
  for (final metric in metrics) {
    double length = metric.length;
    double trimStart = length * startT;
    double trimStop = length * stopT;
    if (complement) {
      bool extractStart = trimStop < length;
      if (extractStart) {
        _appendPathSegmentSync(metric, result, trimStop, length);
      }
      if (trimStart > 0.0) {
        _appendPathSegmentSync(metric, result, 0.0, trimStart,
            startWithMoveTo: !extractStart || !metric.isClosed);
      }
    } else if (trimStart < trimStop) {
      _appendPathSegmentSync(metric, result, trimStart, trimStop);
    }
  }
}

void updateTrimPath(Path path, Path result, double startT, double stopT,
        bool complement, bool isSequential) =>
    isSequential
        ? _trimPathSequential(path, result, startT, stopT, complement)
        : _trimPathSync(path, result, startT, stopT, complement);
