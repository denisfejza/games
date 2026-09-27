import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers.dart';

/// True when the parent turned on reduced motion or the device asks for it.
bool reduceMotion(BuildContext context, WidgetRef ref) =>
    ref.watch(reducedMotionProvider) || MediaQuery.maybeDisableAnimationsOf(context) == true;
