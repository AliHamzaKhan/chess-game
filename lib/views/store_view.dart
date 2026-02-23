import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pay/pay.dart';
import '../widgets/glass_container.dart';

class StoreView extends StatelessWidget {
  const StoreView({super.key});

  final _paymentItems = const [
    PaymentItem(
      label: 'Premium Subscription (Monthly)',
      amount: '4.99',
      status: PaymentItemStatus.final_price,
    )
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Store", style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.amber),
            ),
            child: Row(
              children: [
                const Icon(Icons.monetization_on, color: Colors.amber, size: 16),
                const SizedBox(width: 4),
                const Text("1,250", style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
                  child: const Icon(Icons.add, color: Colors.white, size: 12),
                )
              ],
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSubscriptionCard(context),
            const SizedBox(height: 24),
            _buildSectionHeader("Featured Skins", "View All"),
            const SizedBox(height: 16),
            _buildSkinsGrid(context),
            const SizedBox(height: 24),
            _buildSectionHeader("Top Up Credits", ""),
            const SizedBox(height: 16),
            _buildTopUpSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSubscriptionCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4F46E5), Color(0xFF818CF8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4F46E5).withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 16),
                const SizedBox(width: 4),
                Text(
                  "GRANDMASTER STATUS",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "Unlock Full\nPotential",
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 16),
          _buildFeatureRow("Ad-free experience"),
          const SizedBox(height: 8),
          _buildFeatureRow("Unlimited game analysis"),
          const SizedBox(height: 8),
          _buildFeatureRow("Exclusive monthly skins"),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF4F46E5),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Upgrade for \$4.99/mo", style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward, size: 18),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Google Pay
                GooglePayButton(
                  paymentConfiguration: PaymentConfiguration.fromJsonString('''
                    {
                      "provider": "google_pay",
                      "data": {
                        "environment": "TEST",
                        "apiVersion": 2,
                        "apiVersionMinor": 0,
                        "allowedPaymentMethods": [
                          {
                            "type": "CARD",
                            "tokenizationSpecification": {
                              "type": "PAYMENT_GATEWAY",
                              "parameters": {
                                "gateway": "example",
                                "gatewayMerchantId": "exampleGatewayMerchantId"
                              }
                            },
                            "allowedAuthMethods": ["PAN_ONLY", "CRYPTOGRAM_3DS"],
                            "allowedCardNetworks": ["AMEX", "DISCOVER", "JCB", "MASTERCARD", "VISA"]
                          }
                        ],
                        "merchantInfo": {
                          "merchantName": "Chess Master App"
                        },
                        "transactionInfo": {
                          "countryCode": "US",
                          "currencyCode": "USD"
                        }
                      }
                    }
                  '''), 
                  paymentItems: _paymentItems,
                  type: GooglePayButtonType.subscribe,
                  onPaymentResult: (result) {
                    debugPrint("Google Pay Result: $result");
                    Get.snackbar("Success", "Google Pay subscription processed successfully!");
                  },
                  loadingIndicator: const Center(child: CircularProgressIndicator()),
                ),
                const SizedBox(height: 16),
                // Apple Pay
                ApplePayButton(
                  paymentConfiguration: PaymentConfiguration.fromJsonString('''
                    {
                      "provider": "apple_pay",
                      "data": {
                        "merchantIdentifier": "merchant.com.example.chessmaster",
                        "displayName": "Chess Master",
                        "supportedNetworks": ["visa", "masterCard", "amex"],
                        "countryCode": "US",
                        "currencyCode": "USD"
                      }
                    }
                  '''),
                  paymentItems: _paymentItems,
                  style: ApplePayButtonStyle.black,
                  type: ApplePayButtonType.subscribe,
                  onPaymentResult: (result) {
                    debugPrint("Apple Pay Result: $result");
                    Get.snackbar("Success", "Apple Pay subscription processed successfully!");
                  },
                  loadingIndicator: const Center(child: CircularProgressIndicator()),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildFeatureRow(String text) {
    return Row(
      children: [
        const Icon(Icons.check_circle, color: Colors.white, size: 20),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(color: Colors.white, fontSize: 14)),
      ],
    );
  }

  Widget _buildSectionHeader(String title, String action) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        if (action.isNotEmpty)
          TextButton(
            onPressed: () {},
            child: Text(action, style: const TextStyle(color: Color(0xFF4F46E5))),
          ),
      ],
    );
  }

  Widget _buildSkinsGrid(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 0.8,
      children: [
        _buildSkinCard(context, "Neon Cyberpunk", "850", Colors.purple),
        _buildSkinCard(context, "Minimalist Wood", "450", Colors.green),
        _buildSkinCard(context, "Crystal Glass", "1200", Colors.amber),
        _buildSkinCard(context, "Stone Age", "200", Colors.grey),
      ],
    );
  }

  Widget _buildSkinCard(BuildContext context, String name, String price, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Center(
                child: Icon(Icons.grid_view, size: 48, color: color),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.monetization_on, size: 14, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(price, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.amber)),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.shopping_bag_outlined, size: 16),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopUpSection(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _buildCreditCard(context, "100", "0.99", Colors.amber)),
        const SizedBox(width: 16),
        Expanded(child: _buildCreditCard(context, "550", "4.99", Colors.blue)),
        const SizedBox(width: 16),
        Expanded(child: _buildCreditCard(context, "1200", "9.99", Colors.purple)),
      ],
    );
  }

  Widget _buildCreditCard(BuildContext context, String credits, String price, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(Icons.savings, color: color, size: 32),
          const SizedBox(height: 8),
          Text(credits, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
          const Text("CREDITS", style: TextStyle(fontSize: 10, letterSpacing: 1)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text("\$$price", style: TextStyle(color: color, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
