import 'package:flutter/cupertino.dart';

mixin ScrollViewPositionListener<T extends StatefulWidget> implements State<T> {
  final ScrollController scrollController = ScrollController();
  bool scrolledToBottom = false;
  bool scrolledToTop = true;

  void initScrollListener() {
    scrollController.addListener(() {
      // https://medium.com/@diegoveloper/flutter-lets-know-the-scrollcontroller-and-scrollnotification-652b2685a4ac
      if (scrollController.offset >= scrollController.position.maxScrollExtent) {
        setState(() {
          scrolledToBottom = true;
          scrolledToTop = false;
        });
      } else if (scrollController.offset <= scrollController.position.minScrollExtent) {
        setState(() {
          scrolledToBottom = false;
          scrolledToTop = true;
        });
      } else if (scrolledToTop || scrolledToBottom) {
        setState(() {
          scrolledToBottom = false;
          scrolledToTop = false;
        });
      }
    });
  }

  void disposeScrollListener() {
    scrollController.dispose();
  }
}