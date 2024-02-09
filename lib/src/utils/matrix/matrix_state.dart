import 'package:flutter/widgets.dart';

import 'package:matrix/matrix.dart';
import 'package:provider/provider.dart';

import '../../widgets/matrix/client_manager.dart';

abstract class MatrixState<T extends StatefulWidget> extends State<T> {
  Client get client =>
      Provider.of<GetClientCallback>(context, listen: false).call();
}
