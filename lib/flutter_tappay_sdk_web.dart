import 'package:flutter_tappay_sdk/models/tappay_init_result.dart';
import 'package:flutter_tappay_sdk/models/tappay_prime.dart';
import 'package:flutter_tappay_sdk/models/tappay_sdk_common_result.dart';
import 'package:flutter_tappay_sdk/tappay/auth_methods.dart';
import 'package:flutter_tappay_sdk/tappay/card_type.dart';
import 'package:flutter_tappay_sdk/tappay/cart_item.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'flutter_tappay_sdk_platform_interface.dart';
import 'web/web_adapter_stub.dart'
    if (dart.library.html) 'web/web_adapter_helpers.dart';

class FlutterTapPaySdkWeb extends FlutterTapPaySdkPlatform {
  static void registerWith(Registrar registrar) {
    FlutterTapPaySdkPlatform.instance = FlutterTapPaySdkWeb();
  }

  @override
  Future<TapPayInitResult?> initTapPay({
    required int appId,
    required String appKey,
    bool isSandbox = false,
  }) async {
    final env = isSandbox ? 'sandbox' : 'production';
    await TapPayWebHelpers.instance
        .init(appId: appId, appKey: appKey, env: env);
    return TapPayInitResult(success: true);
  }

  //（選擇）讓 getCardPrime 在 Web 直接從 hosted fields 取 prime
  @override
  Future<TapPayPrime?> getCardPrime({
    required String cardNumber,
    required String dueMonth,
    required String dueYear,
    required String cvv,
  }) async {
    final p = await TapPayWebHelpers.instance.getPrime();
    return TapPayPrime(success: true, prime: p);
  }

  @override
  Future<TapPaySdkCommonResult?> applePayResult({required bool result}) {
    throw UnimplementedError();
  }

  @override
  Future<TapPaySdkCommonResult?> initApplePay({
    required String merchantId,
    required String merchantName,
    List<TapPayCardType>? allowedCardTypes,
    bool? isConsumerNameRequired = false,
    bool? isPhoneNumberRequired = false,
    bool? isEmailRequired = false,
    bool? isBillingAddressRequired = false,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<TapPaySdkCommonResult?> initGooglePay({
    required String merchantName,
    List<TapPayCardAuthMethod>? allowedAuthMethods,
    List<TapPayCardType>? allowedCardTypes,
    bool? isPhoneNumberRequired = false,
    bool? isEmailRequired = false,
    bool? isBillingAddressRequired = false,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<bool> isCardValid({
    required String cardNumber,
    required String dueMonth,
    required String dueYear,
    required String cvv,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<TapPayPrime?> requestApplePay({
    required List<CartItem> cartItems,
    required String currencyCode,
    required String countryCode,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<TapPayPrime?> requestGooglePay({
    required double price,
    required String currencyCode,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<String?> get tapPaySdkVersion async {
    return 'Web not supported';
  }
}
