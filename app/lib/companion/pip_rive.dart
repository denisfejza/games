import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rive/rive.dart' as rive;

import 'pip_controller.dart';

/// Where the artist's file goes. Also add `- assets/rive/` to pubspec.yaml.
const pipRiveAsset = 'assets/rive/pip.riv';

/// True once `assets/rive/pip.riv` is bundled. The Rive runtime is only
/// started then, so builds without the file load nothing extra.
final pipRiveAvailableProvider = FutureProvider<bool>((ref) async {
  final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
  if (!manifest.listAssets().contains(pipRiveAsset)) return false;
  return rive.RiveNative.init();
});

/// Pip from the Rive file: default artboard, state machine `Pip`, and a view
/// model with numbers `mood` (PipMood index) and `mouth` (0–100), bound
/// automatically. See docs/PIP_RIVE_SPEC.md.
class RivePip extends StatefulWidget {
  const RivePip({super.key, required this.mood, required this.mouth, required this.fallback});

  final PipMood mood;

  /// 0–1 mouth opening while talking.
  final double mouth;

  /// Shown while loading or if the file doesn't match the spec.
  final Widget fallback;

  @override
  State<RivePip> createState() => _RivePipState();
}

class _RivePipState extends State<RivePip> {
  late final rive.FileLoader _loader = rive.FileLoader.fromAsset(pipRiveAsset, riveFactory: rive.Factory.rive);
  rive.ViewModelInstanceNumber? _mood;
  rive.ViewModelInstanceNumber? _mouth;

  @override
  void didUpdateWidget(RivePip old) {
    super.didUpdateWidget(old);
    _apply();
  }

  void _apply() {
    _mood?.value = widget.mood.index.toDouble();
    _mouth?.value = widget.mouth * 100;
  }

  @override
  void dispose() {
    _loader.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => rive.RiveWidgetBuilder(
    fileLoader: _loader,
    stateMachineSelector: rive.StateMachineSelector.byName('Pip'),
    dataBind: rive.DataBind.auto(),
    onLoaded: (state) {
      _mood = state.viewModelInstance?.number('mood');
      _mouth = state.viewModelInstance?.number('mouth');
      _apply();
    },
    builder: (context, state) => switch (state) {
      rive.RiveLoaded() => rive.RiveWidget(controller: state.controller, fit: rive.Fit.contain),
      _ => widget.fallback,
    },
  );
}
