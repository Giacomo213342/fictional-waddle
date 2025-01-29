import 'package:flutter/material.dart';

import 'package:matrix/encryption.dart';
import 'package:matrix/matrix.dart';

import '../matrix_scope.dart';
import 'components/compare_sas_widget.dart';
import 'components/incoming_verification_request_widget.dart';
import 'components/ssss_recovery_input.dart';
import 'components/verification_request_error_widget.dart';
import 'components/verification_successful_widget.dart';
import 'components/waiting_peer_widget.dart';

typedef ButtonBarBuilder = Widget Function(
  BuildContext context,
  List<Widget> children,
);

class KeyVerificationRequestWidget extends StatefulWidget {
  const KeyVerificationRequestWidget(
    this.request, {
    super.key,
    this.onClose,
    this.buttonBarBuilder = defaultButtonBarBuilder,
    this.client,
  });

  static Widget defaultButtonBarBuilder(
    BuildContext context,
    List<Widget> children,
  ) =>
      Material(
        color: Theme.of(context).colorScheme.primary,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: switch (children.length) {
              1 => children,
              2 => [
                  Expanded(child: children.first),
                  const SizedBox(
                    width: 16,
                  ),
                  Expanded(child: children.last),
                ],
              int() => [
                  Expanded(
                    child: OverflowBar(
                      children: children,
                    ),
                  ),
                ]
            },
          ),
        ),
      );

  final KeyVerification request;
  final ButtonBarBuilder buttonBarBuilder;
  final VoidCallback? onClose;
  final Client? client;

  @override
  State<KeyVerificationRequestWidget> createState() =>
      _KeyVerificationRequestWidgetState();

  static Future<void> showDialog(
    KeyVerification request, {
    required BuildContext context,
    required Client client,
  }) {
    return showModalBottomSheet(
      context: context,
      isDismissible: false,
      useRootNavigator: true,
      builder: (context) => MatrixScope(
        scope: (client, null, null, null),
        child: KeyVerificationRequestWidget(
          request,
          onClose: Navigator.of(context).pop,
        ),
      ),
    );
  }
}

class _KeyVerificationRequestWidgetState
    extends State<KeyVerificationRequestWidget> {
  Profile? peer;

  @override
  void initState() {
    super.initState();
    widget.request.onUpdate = handleNextStep;
    loadLazyData();
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.request.state) {
      case KeyVerificationState.askAccept:
        return IncomingVerificationRequestWidget(
          widget.request,
          profile: peer,
          onAccept: _acceptVerificationRequest,
          onReject: _rejectVerificationRequest,
          buttonBarBuilder: widget.buttonBarBuilder,
          client: widget.client,
        );
      case KeyVerificationState.askSSSS:
        return SsssRecoveryInput(
          widget.request,
          onSubmit: _submitRecoveryKey,
          buttonBarBuilder: widget.buttonBarBuilder,
          client: widget.client,
        );
      loading:
      case KeyVerificationState.askChoice:
      case KeyVerificationState.waitingAccept:
        return WaitingPeerWidget(
          peer,
          buttonBarBuilder: widget.buttonBarBuilder,
          onCancel: _cancelVerificationRequest,
          client: widget.client,
        );
      case KeyVerificationState.askSas:
        return CompareSasWidget(
          widget.request,
          onAccept: _confirmSas,
          onReject: _rejectSas,
          buttonBarBuilder: widget.buttonBarBuilder,
        );
      case KeyVerificationState.showQRSuccess:
      case KeyVerificationState.confirmQRScan:
        throw UnimplementedError(
          'QR verification is not supported by this client.',
        );

      case KeyVerificationState.error:
        if (widget.request.canceledCode == 'm.accepted' ||
            widget.request.canceledReason == 'm.accepted') {
          continue loading;
        }
        return VerificationRequestErrorWidget(
          widget.request,
          onClose: _closeDialog,
          buttonBarBuilder: widget.buttonBarBuilder,
        );
      case KeyVerificationState.waitingSas:
      case KeyVerificationState.done:
        return VerificationSuccessfulWidget(
          onClose: _closeDialog,
          buttonBarBuilder: widget.buttonBarBuilder,
        );
    }
  }

  void handleNextStep() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> loadLazyData() async {
    final userId = widget.request.userId;
    // TODO: fallback on cached profile by direct chat
    final profile = await widget.client?.getProfileFromUserId(userId);
    setState(() {
      peer = profile;
    });
  }

  Future<void> _submitRecoveryKey(String cipher) async {
    try {
      await widget.request.openSSSS(keyOrPassphrase: cipher);
    } catch (e) {
      // TODO: handle error
    }
  }

  Future<void> _cancelVerificationRequest() async {
    // TODO: Better handle cancellation of verification request
    widget.request.cancel();
    widget.onClose?.call();
  }

  Future<void> _rejectVerificationRequest() =>
      widget.request.rejectVerification();

  Future<void> _acceptVerificationRequest() =>
      widget.request.acceptVerification();

  Future<void> _confirmSas() => widget.request.acceptSas();

  Future<void> _rejectSas() => widget.request.rejectSas();

  void _closeDialog() => widget.onClose?.call();
}
