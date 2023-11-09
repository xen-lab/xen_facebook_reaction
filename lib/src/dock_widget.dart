// BSD License. Copyright © Kiran Paudel. All rights reserved

import 'package:animated_emoji/emojis.dart';
import 'package:flutter/material.dart';

///
class DockWidget extends StatefulWidget {
  /// dock widget containing list of available reaction emojis
  /// [AnimatedEmojiData].
  const DockWidget({
    required this.reactionEmojis,
    this.initialPlaceholder,
    this.initialEmoji,
    this.size,
    super.key,
  }) : assert(
          initialPlaceholder != null || initialEmoji != null,
          'either [initialPlacehoder] or [initialEmoji] is required',
        );

  /// list of [AnimatedEmojiData]
  ///
  final List<AnimatedEmojiData> reactionEmojis;

  /// [Widget] to display user before any reaction is selected
  ///
  final Widget? initialPlaceholder;

  /// initial emoji to show the user
  ///
  /// useful when displaying a reaction based on previous selection
  ///
  /// when null [initialPlaceholder] will be displayed
  final AnimatedEmojiData? initialEmoji;

  /// adjust size of dock
  final Size? size;

  @override
  State<DockWidget> createState() => _DockWidgetState();
}

class _DockWidgetState extends State<DockWidget> with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

///
class Dock extends StatelessWidget {
  ///
  const Dock({super.key, this.size = const Size(200, 10)});

  ///
  final Size size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size.width,
      height: size.height,
      decoration: BoxDecoration(
        color: const Color.fromARGB(201, 255, 255, 255),
        borderRadius: BorderRadius.circular(20),
      ),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.all(10),
        children: List.generate(10, (i) {
          return AnimatedBuilder(
            animation: _zoomAnimations[i],
            builder: (context, child) {
              return GestureDetector(
                onTap: () {
                  _zoomSelectedEmojiController.forward(from: 0);
                  setState(() {
                    _selectedEmoji = AnimatedEmojis.values[i + 10];
                  });
                  hideReactionOverlay();
                },
                child: Tooltip(
                  waitDuration: Duration.zero,
                  message: 'Emoji $i',
                  child: AnimatedEmoji(
                    source: AnimatedEmojiSource.asset,
                    AnimatedEmojis.clapDark,
                    size: _zoomAnimations[i].value,
                    // repeat: false,
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}
