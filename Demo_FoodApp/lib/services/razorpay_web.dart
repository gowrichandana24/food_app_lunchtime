import 'dart:html' as html;
import 'dart:js' as js;
import 'dart:js_util' as js_util;

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
    final options = {
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
      'handler': js.allowInterop((response) {
        _paymentSuccessCallback({
          'paymentId': js_util.getProperty(response, 'razorpay_payment_id'),
          'orderId': js_util.getProperty(response, 'razorpay_order_id'),
          'signature': js_util.getProperty(response, 'razorpay_signature'),
        });
      }),
      'modal': {
        'ondismiss': js.allowInterop(() {
          _paymentErrorCallback('Payment cancelled');
        })
      }
    };

    final razorpay = js_util.callConstructor(
      js_util.getProperty(html.window, 'Razorpay'),
      [js_util.jsify(options)],
    );
    js_util.callMethod(razorpay, 'open', []);
  } catch (e) {
    _paymentErrorCallback('Error opening Razorpay checkout: $e');
  }
}

void disposeRazorpay() {}
