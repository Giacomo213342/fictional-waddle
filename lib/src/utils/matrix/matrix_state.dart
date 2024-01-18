import 'package:flutter/widgets.dart';

import 'package:matrix/matrix.dart';
import 'package:provider/provider.dart';

abstract class MatrixState<T extends StatefulWidget> extends State<T> {
  Client get client => Provider.of<Client>(context, listen: false);
}
