import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sweet_shop_app_ui/core/theme/dimens.dart';
import 'package:flutter_sweet_shop_app_ui/core/theme/theme.dart';
import 'package:flutter_sweet_shop_app_ui/core/utils/sized_context.dart';
import 'package:flutter_sweet_shop_app_ui/core/widgets/app_divider.dart';
import 'package:flutter_sweet_shop_app_ui/core/widgets/app_scaffold.dart';
import 'package:flutter_sweet_shop_app_ui/core/widgets/general_app_bar.dart';
import 'package:flutter_sweet_shop_app_ui/core/widgets/google_address_input.dart';

import '../../../../core/gen/assets.gen.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_svg_viewer.dart';

class ChangeAddressScreen extends StatefulWidget {
  const ChangeAddressScreen({super.key});

  @override
  State<ChangeAddressScreen> createState() => _ChangeAddressScreenState();
}

class _ChangeAddressScreenState extends State<ChangeAddressScreen> {
  final List<AddressItem> _savedAddresses = [
    AddressItem(
      id: '1',
      title: 'Ev',
      address: 'Saraçlar Cd. Merkez, Edirne',
      isSelected: true,
    ),
    AddressItem(
      id: '2',
      title: 'Ofis',
      address: 'İstasyon Caddesi No:15, Edirne',
      isSelected: false,
    ),
    AddressItem(
      id: '3',
      title: 'Aile evi',
      address: 'Kaleiçi Mahallesi, Edirne',
      isSelected: false,
    ),
  ];

  void _selectAddress(String id) {
    setState(() {
      for (var address in _savedAddresses) {
        address.isSelected = address.id == id;
      }
    });
  }

  void _addNewAddress(String address) {
    setState(() {
      _savedAddresses.add(
        AddressItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: 'Yeni Adres',
          address: address,
          isSelected: true,
        ),
      );
      // Unselect all others
      for (var addr in _savedAddresses) {
        if (addr.address != address) {
          addr.isSelected = false;
        }
      }
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Yeni adres eklendi'),
        backgroundColor: context.theme.appColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appTypography = context.theme.appTypography;
    final appColors = context.theme.appColors;
    
    return AppScaffold(
      appBar: GeneralAppBar(title: 'Adres Değiştir'),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Saved Addresses
            ListView.separated(
              itemCount: _savedAddresses.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                final address = _savedAddresses[index];
                return InkWell(
                  onTap: () => _selectAddress(address.id),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: AppSvgViewer(
                          Assets.icons.location,
                          color: appColors.primary,
                        ),
                        title: Text(
                          address.title,
                          style: appTypography.bodyLarge,
                        ),
                        trailing: Radio(
                          value: address.isSelected,
                          groupValue: true,
                          onChanged: (_) => _selectAddress(address.id),
                          activeColor: appColors.primary,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 42,
                          right: Dimens.largePadding,
                          bottom: Dimens.largePadding,
                        ),
                        child: Text(
                          address.address,
                          style: appTypography.bodySmall.copyWith(
                            color: appColors.gray4,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              },
              separatorBuilder: (context, index) => const AppDivider(),
            ),
            
            const SizedBox(height: Dimens.veryLargePadding),
            
            // Add New Address with Google Places
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Dimens.largePadding),
              child: GoogleAddressInput(
                onAddressSelected: _addNewAddress,
                hintText: '+ Yeni adres ekle (Google Maps\'ten seç)',
                showLabel: false,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(
          left: Dimens.largePadding,
          right: Dimens.largePadding,
          bottom: Dimens.padding,
        ),
        child: AppButton(
          onPressed: () {
            final selectedAddress = _savedAddresses.firstWhere(
              (addr) => addr.isSelected,
              orElse: () => _savedAddresses.first,
            );
            
            Navigator.of(context).pop(selectedAddress.address);
          },
          title: 'Uygula',
          textStyle: appTypography.bodyLarge,
          borderRadius: Dimens.corners,
          margin: const EdgeInsets.symmetric(vertical: Dimens.largePadding),
        ),
      ),
    );
  }
}

class AddressItem {
  AddressItem({
    required this.id,
    required this.title,
    required this.address,
    required this.isSelected,
  });

  final String id;
  final String title;
  final String address;
  bool isSelected;
}
