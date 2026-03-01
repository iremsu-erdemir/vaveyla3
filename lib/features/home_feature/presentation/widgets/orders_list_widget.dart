import 'package:flutter/material.dart';
import 'package:flutter_sweet_shop_app_ui/core/theme/theme.dart';
import 'package:flutter_sweet_shop_app_ui/core/widgets/app_divider.dart';
import 'package:flutter_sweet_shop_app_ui/core/widgets/modern_order_card.dart';
import 'package:flutter_sweet_shop_app_ui/core/widgets/app_button.dart';
import 'package:flutter_sweet_shop_app_ui/core/utils/formatters.dart';

import '../../../../core/theme/dimens.dart';
import '../../data/data_source/local/sample_data.dart';

enum OrderType { active, completed, canceled }

class OrdersListWidget extends StatelessWidget {
  const OrdersListWidget({super.key, required this.orderType});

  final OrderType orderType;

  @override
  Widget build(BuildContext context) {
    final appColors = context.theme.appColors;
    return ListView.separated(
      itemCount: categoryProductsImage.length,
      itemBuilder: (final context, final index) {
        return Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Dimens.largePadding,
          ),
          child: ModernOrderCard(
            productName: 'Sünger donut',
            price: (index + 1) * 1800, // Convert to cents/kuruş (18.00 ₺ = 1800)
            imageUrl: categoryProductsImage[index],
            quantity: index + 3,
            dateTime: '01.03.2026 • 11:53', // Sample date
            status: _getStatusForOrderType(orderType),
            statusColor: _getStatusColorForOrderType(orderType, appColors),
            actionButton: _buildActionButton(context, orderType, appColors),
            onTap: () {
              // Handle order card tap
            },
          ),
        );
      },
      separatorBuilder: (final context, final index) {
        return const SizedBox(height: Dimens.largePadding);
      },
    );
  }

  String _getStatusForOrderType(OrderType orderType) {
    switch (orderType) {
      case OrderType.active:
        return 'Hazırlanıyor';
      case OrderType.completed:
        return 'Tamamlandı';
      case OrderType.canceled:
        return 'İptal edildi';
    }
  }

  Color? _getStatusColorForOrderType(OrderType orderType, dynamic appColors) {
    switch (orderType) {
      case OrderType.active:
        return appColors.primary;
      case OrderType.completed:
        return appColors.success;
      case OrderType.canceled:
        return appColors.error;
    }
  }

  Widget? _buildActionButton(BuildContext context, OrderType orderType, dynamic appColors) {
    return SizedBox(
      width: 110,
      height: 32,
      child: AppButton(
        title: orderType == OrderType.active
            ? 'Siparişi takip et'
            : orderType == OrderType.completed
            ? 'Teslim edildi'
            : 'Tekrar sipariş ver',
        color: orderType == OrderType.active
            ? appColors.primary
            : orderType == OrderType.completed
            ? appColors.successLight
            : appColors.error,
        margin: EdgeInsets.zero,
        padding: WidgetStateProperty.all<EdgeInsets>(
          const EdgeInsets.symmetric(horizontal: Dimens.padding),
        ),
        onPressed: () {},
      ),
    );
  }
}
