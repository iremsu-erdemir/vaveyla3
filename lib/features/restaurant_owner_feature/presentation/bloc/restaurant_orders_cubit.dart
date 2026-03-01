import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sweet_shop_app_ui/features/restaurant_owner_feature/data/models/order_model.dart';
import 'package:flutter_sweet_shop_app_ui/features/restaurant_owner_feature/data/services/restaurant_owner_service.dart';

class RestaurantOrdersCubit extends Cubit<List<RestaurantOrderModel>> {
  RestaurantOrdersCubit(this._service, this._ownerUserId) : super(const []);

  final RestaurantOwnerService _service;
  final String _ownerUserId;

  Future<void> loadOrders() async {
    final orders = await _service.getOrders(ownerUserId: _ownerUserId);
    emit(orders);
  }

  Future<void> acceptOrder(String id) async {
    await _updateOrderStatusRemote(id, RestaurantOrderStatus.preparing);
  }

  Future<void> rejectOrder(String id) async {
    await _service.updateOrderStatus(
      ownerUserId: _ownerUserId,
      id: id,
      status: RestaurantOrderStatus.rejected,
    );
    emit(state.where((o) => o.id != id).toList());
  }

  Future<void> markReady(String id) async {
    await _updateOrderStatusRemote(id, RestaurantOrderStatus.completed);
  }

  Future<void> _updateOrderStatusRemote(
    String id,
    RestaurantOrderStatus to,
  ) async {
    final updated = await _service.updateOrderStatus(
      ownerUserId: _ownerUserId,
      id: id,
      status: to,
    );
    emit(state.map((order) {
      if (order.id == id) {
        return updated;
      }
      return order;
    }).toList());
  }

  Future<void> addOrder(
    String items,
    int total, {
    String? imagePath,
    int? preparationMinutes,
    RestaurantOrderStatus? status,
    DateTime? createdAt,
  }) async {
    final created = await _service.createOrder(
      ownerUserId: _ownerUserId,
      items: items,
      total: total,
      imagePath: imagePath,
      preparationMinutes: preparationMinutes,
      status: status?.name,
      createdAt: createdAt,
    );
    emit([created, ...state]);
  }

  List<RestaurantOrderModel> getByStatus(RestaurantOrderStatus status) {
    return state.where((o) => o.status == status).toList();
  }
}
