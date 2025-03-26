import 'dart:convert';
import 'package:http/http.dart' as http;

class SubscriptionService {
  final String _baseUrl = 'https://getsubscriptionprices-fnzltfhora-uc.a.run.app'; // Replace with your Cloud Functions URL

  Future<Map<String, dynamic>?> getSubscriptionPrices() async {
    try {
      final response = await http.get(Uri.parse(_baseUrl));

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        print('Failed to load subscription prices: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error fetching subscription prices: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> applyCoupon(String couponCode) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/applyCoupon?couponCode=$couponCode'));

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        print('Failed to apply coupon: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error applying coupon: $e');
      return null;
    }
  }
}