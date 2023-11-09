// BSD License. Copyright © Kiran Paudel. All rights reserved

import 'package:animated_emoji/emoji.dart';
import 'package:animated_emoji/emojis.dart';
import 'package:flutter/material.dart';

///
class ReactionButton extends StatefulWidget {
  ///
  const ReactionButton({super.key});

  @override
  State<ReactionButton> createState() => _ReactionButtonState();
}

class _ReactionButtonState extends State<ReactionButton>
    with TickerProviderStateMixin {
  late List<AnimationController> _zoomControllers;
  late List<Animation<double>> _zoomAnimations;
  late Animation<double> _zoomSelectedEmojiAnimation;
  late AnimationController _zoomSelectedEmojiController;

  late LayerLink layerLink;
  late GlobalKey selectedWidgetKey;
  late GlobalKey reactionWidgetKey;
  late OverlayEntry? overlayEntry;
  late Offset overlayOffset;

  final _reactionWidgetHeight = 100.0;
  final _reactionWidgetWidth = 500.0;

  dynamic _selectedEmoji;

  @override
  void initState() {
    super.initState();
    _selectedEmoji = Container(
      decoration:
          const BoxDecoration(color: Colors.white10, shape: BoxShape.circle),
      child: const Icon(Icons.add_to_photos_rounded, size: 20),
    );

    _zoomControllers = List.generate(10, (index) {
      return AnimationController(
          vsync: this, duration: const Duration(milliseconds: 100));
    });

    _zoomAnimations = _zoomControllers.map((controller) {
      return Tween<double>(begin: 50, end: 70).animate(controller);
    }).toList();

    _zoomSelectedEmojiController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 100));
    _zoomSelectedEmojiAnimation =
        Tween<double>(begin: 0, end: 50).animate(_zoomSelectedEmojiController);

    selectedWidgetKey = GlobalKey();
    reactionWidgetKey = GlobalKey();
    layerLink = LayerLink();
  }

  void _calculatePosition() {
    if (selectedWidgetKey.currentContext != null) {
      final renderBox =
          selectedWidgetKey.currentContext!.findRenderObject()! as RenderBox;
      overlayOffset = renderBox.localToGlobal(Offset.zero);
    }
  }

  void showReactionOverlay() {
    _calculatePosition();
    final overlayState = Overlay.of(context);
    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: overlayOffset.dx - 500 / 2,
        top: overlayOffset.dy - 120,
        child:
            CompositedTransformFollower(link: layerLink, child: _reactions()),
      ),
    );
    overlayState.insert(overlayEntry!);
  }

  void hideReactionOverlay() {
    overlayEntry!.remove();
  }

  @override
  void dispose() {
    for (final controller in _zoomControllers) {
      controller.dispose();
    }
    _zoomSelectedEmojiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: showReactionOverlay,
      child: MouseRegion(
        child: Container(
          key: selectedWidgetKey,
          width: 45,
          height: 45,
          decoration: const BoxDecoration(
              color: Colors.white24, shape: BoxShape.circle),
          child: AnimatedBuilder(
            animation: _zoomSelectedEmojiController,
            builder: (context, child) {
              if (_selectedEmoji.runtimeType == Container) {
                return _selectedEmoji as Widget;
              } else {
                return Padding(
                  padding: const EdgeInsets.all(8),
                  child: AnimatedEmoji(
                    _selectedEmoji as AnimatedEmojiData,
                    repeat: false,
                    size: _zoomSelectedEmojiAnimation.value,
                  ),
                );
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _reactions() {
    return Container(
      decoration: BoxDecoration(
        color: const Color.fromARGB(201, 255, 255, 255),
        borderRadius: BorderRadius.circular(20),
      ),
      width: _reactionWidgetWidth,
      height: _reactionWidgetHeight,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.all(10),
        children: List.generate(10, (i) {
          return MouseRegion(
            onEnter: (x) => _zoomControllers[i].forward(),
            onExit: (x) => _zoomControllers[i].reverse(),
            child: AnimatedBuilder(
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
            ),
          );
        }),
      ),
    );
  }
}
