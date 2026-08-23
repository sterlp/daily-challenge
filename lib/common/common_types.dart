import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';

class MyStyle {
  static const COST_ICON = Icon(Icons.star, color: Colors.amber);
  static const GOAL_ICON = Icon(MdiIcons.trophy, color: Colors.amber);

  static const REWARD_ICON = Icon(MdiIcons.trophy, color: Colors.amber);

  static const ICON_DONE_CHALLENGE = Icons.star;
  static const ICON_PENDING_CHALLENGE = Icons.star_border;
  static const ICON_FAILED_CHALLENGE = MdiIcons.starOff;

  static const POSITIVE_BUDGET_COLOR = Colors.green;

  static const EdgeInsets LIST_PADDING = EdgeInsets.all(4);
  static const Divider LIST_DIVIDER = Divider(height: 1, thickness: 1.5);
}
