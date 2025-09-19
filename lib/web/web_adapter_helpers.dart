import 'dart:async';
import 'dart:js_interop';

@JS('tappayInit')
external bool _tappayInit(num appId, String appKey, String env);

@JS('tappayRenderFields')
external bool _tappayRenderFields(String hostId);

@JS('tappayUnmountFields')
external void _tappayUnmountFields(String hostId);

@JS('tappayGetPrime')
external void _tappayGetPrime(JSFunction cb);

@JS('JSON.stringify')
external JSString _jsonStringify(JSAny? value, [JSAny? replacer, JSAny? space]);

String prettyJs(JSAny any) {
  return _jsonStringify(any, null, 2.toJS).toDart;
}

class TapPayWebHelpers {
  TapPayWebHelpers._();
  static final instance = TapPayWebHelpers._();

  bool _inited = false;
  bool _rendered = false;
  String? _lastHostId;

  Future<void> init(
      {required int appId, required String appKey, required String env}) async {
    final ok = _tappayInit(appId, appKey, env);
    if (!ok) throw Exception('TapPay init failed');
    _inited = true;
  }

  Future<void> renderField(String hostId) async {
    if (!_inited) throw StateError('tappay not init');
    final ok = _tappayRenderFields(hostId);
    if (!ok) throw Exception('Render fields failed');
    _rendered = true;
    _lastHostId = hostId;
  }

  Future<String> getPrime() async {
    if (!_inited) throw StateError('tappay not init');
    if (!_rendered) throw StateError('fields not rendered');
    if (_lastHostId == null) throw StateError('no host id');
    final completer = Completer<String>();
    _tappayGetPrime(
      ((JSString? jsPrime, JSAny result) {
        final prime = jsPrime?.toDart; // JSString -> String?
        final pretty = prettyJs(result); // <= 直接拿可讀 JSON
        if (prime != null && prime.isNotEmpty) {
          completer.complete(prime);
        } else {
          completer.completeError(Exception('Get prime failed: $pretty'));
        }
      }).toJS,
    );
    return completer.future;
  }

  Future<String> getStringFromPromise(JSPromise<JSString> jsPromise) async {
    final JSString jsString = await jsPromise.toDart;
    return jsString.toDart; // Convert JSString to Dart String
  }

  Future<void> unmountField(String hostId) async {
    if (!_inited) return;
    if (!_rendered) return;
    if (_lastHostId != hostId) return;
    _tappayUnmountFields(hostId);
    _rendered = false;
    _lastHostId = null;
  }
}
