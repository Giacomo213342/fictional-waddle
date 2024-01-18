import 'package:flutter/material.dart';

import 'fatal_error_view.dart';

class FatalErrorPage extends StatefulWidget {
  const FatalErrorPage({super.key, this.error});

  static const routeName = '/fatal';

  final Object? error;

  @override
  State<FatalErrorPage> createState() => FatalErrorController();
}

class FatalErrorController extends State<FatalErrorPage> {
  Object? get error => widget.error;

  @override
  Widget build(BuildContext context) => FatalErrorView(this);
}
