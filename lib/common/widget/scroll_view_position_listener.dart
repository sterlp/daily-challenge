import 'package:flutter/material.dart';

mixin ScrollViewPositionListener<T extends StatefulWidget> on State<T> {
  final ScrollController scrollController = ScrollController();
  bool scrolledToBottom = false;
  bool scrolledToTop = true;
  bool showFab = true;

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
    var newScrolledToBottom;
    var newScrolledToTop;
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
    if (!newScrolledToBottom) showFab = true;
    if (scrolledToBottom != newScrolledToBottom || scrolledToTop != newScrolledToTop) {
      setState(() {
        scrolledToBottom = newScrolledToBottom;
        scrolledToTop = newScrolledToTop;
      });
    }
  }
}