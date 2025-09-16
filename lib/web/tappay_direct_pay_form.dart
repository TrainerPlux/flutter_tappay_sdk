import 'dart:ui_web' as ui;
import 'package:web/web.dart' as web;
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'web_adapter_stub.dart'
    if (dart.library.html) 'web_adapter_helpers.dart';

class TapPayDirectPayController {
  Future<String> getPrime() => TapPayWebHelpers.instance.getPrime();
}

class TapPayDirectPayForm extends StatefulWidget {
  const TapPayDirectPayForm(
      {super.key, required this.controller, this.width, this.height});
  final TapPayDirectPayController controller;
  final double? width;
  final double? height;
  @override
  State<TapPayDirectPayForm> createState() => _TapPayDirectPayFormState();
}

class _TapPayDirectPayFormState extends State<TapPayDirectPayForm> {
  late final String _viewType;
  late final String _hostId;
  late final web.HTMLDivElement _host;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) return;

    final stamp = DateTime.now().microsecondsSinceEpoch.toString();
    _viewType = 'tappay-host-view-$stamp';
    _hostId = 'tappay-host-$stamp';

    _host = web.HTMLDivElement()
      ..id = _hostId
      ..style.width = '100%'
      ..style.height = '100%'
      ..style.padding = '8px 0';

    ui.platformViewRegistry.registerViewFactory(_viewType, (int _) => _host);
  }

  @override
  void dispose() {
    if (kIsWeb) {
      TapPayWebHelpers.instance.unmountField(_hostId);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) return const SizedBox.shrink();
    return SizedBox(
      width: widget.width ?? double.infinity,
      height: widget.height ?? 180,
      child: HtmlElementView(
        viewType: _viewType,
        onPlatformViewCreated: (id) {
          TapPayWebHelpers.instance.renderField(_host.id);
        },
      ),
    );
  }
}
