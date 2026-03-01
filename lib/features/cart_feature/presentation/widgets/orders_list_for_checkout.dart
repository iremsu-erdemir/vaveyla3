import 'package:flutter/material.dart';
import 'package:flutter_sweet_shop_app_ui/core/theme/theme.dart';
import 'package:flutter_sweet_shop_app_ui/core/utils/formatters.dart';
import 'package:flutter_sweet_shop_app_ui/core/widgets/app_divider.dart';
import 'package:flutter_sweet_shop_app_ui/core/widgets/modern_order_card.dart';

import '../../../../core/theme/dimens.dart';
import '../../../home_feature/data/data_source/local/sample_data.dart';

class OrdersListForCheckout extends StatelessWidget {
  const OrdersListForCheckout({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: categoryProductsImage.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (final context, final index) {
        return CompactOrderCard(
          productName: 'Sünger donut',
          price: (index + 1) * 1800, // Convert to cents/kuruş (18.00 ₺ = 1800)
          imageUrl: categoryProductsImage[index],
          quantity: index + 3,
          onTap: () {
            // Handle checkout item tap if needed
          },
        );
      },
      separatorBuilder: (final context, final index) {
        return const SizedBox(height: Dimens.padding);
      },
    );
  }
}
