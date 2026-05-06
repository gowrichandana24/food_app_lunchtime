import 'dart:js' as js;

late void Function(Map<String, dynamic>) _paymentSuccessCallback;
late void Function(String) _paymentErrorCallback;

Future<void> initRazorpay(
  void Function(Map<String, dynamic>) onSuccess,
  void Function(String) onError,
) async {
  _paymentSuccessCallback = onSuccess;
  _paymentErrorCallback = onError;
}

Future<void> openRazorpayCheckout(
  Map<String, dynamic> razorpayOrder,
  String email,
) async {
  try {
    final options = js.JsObject.jsify({
      'key': 'rzp_test_SlvgRUZCtwvlVA',
      'amount': razorpayOrder['amount'],
      'currency': razorpayOrder['currency'] ?? 'INR',
      'name': 'Food App Lunchtime',
      'order_id': razorpayOrder['id'],
      'description': 'Order Payment',
      'prefill': {
        'email': email,
        'contact': '',
      },
      'theme': {
        'color': '#0F4CFF',
      },
      'handler': (response) {
        _paymentSuccessCallback({
          'paymentId': response['razorpay_payment_id'],
          'orderId': response['razorpay_order_id'],
          'signature': response['razorpay_signature'],
        });
      },
      'modal': {
        'ondismiss': () {
          _paymentErrorCallback('Payment cancelled');
        }
      }
    });

    final razorpayConstructor = js.context['Razorpay'];
    final razorpay = js.JsObject(razorpayConstructor, [options]);
    razorpay.callMethod('open', []);
  } catch (e) {
    _paymentErrorCallback('Error opening Razorpay checkout: $e');
  }
}

void disposeRazorpay() {}
