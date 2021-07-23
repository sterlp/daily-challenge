import 'package:flutter/material.dart';

mixin ScrollViewPositionListener<T extends StatefulWidget> on State<T> {
  final ScrollController scrollController = ScrollController();
  final ValueNotifier<bool> scrolledToBottom = ValueNotifier(false);
  final ValueNotifier<bool> scrolledToTop = ValueNotifier(true);
  final ValueNotifier<bool> showFab = ValueNotifier(true);

  @mustCallSuper
  @override
  void initState() {
    scrollController.addListener(calculateScrollStatus);
    super.initState();
  }
  @override
  @mustCallSuper
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }
  void calculateScrollStatus() {
    bool newScrolledToBottom;
    bool newScrolledToTop;
    // https://medium.com/@diegoveloper/flutter-lets-know-the-scrollcontroller-and-scrollnotification-652b2685a4ac
    if (scrollController.offset >= scrollController.position.maxScrollExtent) {
      newScrolledToBottom = true;
      newScrolledToTop = false;
    } else if (scrollController.offset <= scrollController.position.minScrollExtent) {
      newScrolledToBottom = false;
      newScrolledToTop = true;
    } else {
      newScrolledToBottom = false;
      newScrolledToTop = false;
    }
    onChangeScroll(newScrolledToBottom, newScrolledToTop);
  }

  void onChangeScroll(bool newScrolledToBottom, bool newScrolledToTop) {
    if (!newScrolledToBottom) showFab.value = true;
    if (scrolledToBottom.value != newScrolledToBottom
        || scrolledToTop.value != newScrolledToTop) {
      scrolledToBottom.value = newScrolledToBottom;
      scrolledToTop.value = newScrolledToTop;
    }
  }
}