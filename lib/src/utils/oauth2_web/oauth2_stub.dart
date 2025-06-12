Stream<Uri> listenWebBroadcastChannel() =>
    const Stream<Uri>.empty(broadcast: true);

bool get isWebHostedOrigin => false;

Uri get webHostedOrigin => Uri();
