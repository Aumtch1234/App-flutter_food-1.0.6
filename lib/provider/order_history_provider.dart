import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:project/model/menu_item.dart';

class OrderHistoryProvider with ChangeNotifier {
  final List<Map<String, dynamic>> _orders = [];

  List<Map<String, dynamic>> get orders => _orders;

  void addOrder(String orderId, String date, double total, double rating,
      List<MenuItem> items) {
    _orders.add({
      'orderId': orderId,
      'date': date,
      'total': total,
      'rating': rating,
      'items': items.map((item) => item.toMap()).toList(),
    });

    notifyListeners();
  }

  // ✅ ดึงข้อมูลเฉพาะของวันนี้
  Map<String, dynamic> getTodaySummary() {
    String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    List<Map<String, dynamic>> todayOrders =
        _orders.where((order) => order['date'].startsWith(today)).toList();

    return _calculateSummary(todayOrders);
  }

  // ✅ ดึงข้อมูลรายเดือน
  Map<String, dynamic> getMonthlySummary() {
    String currentMonth = DateFormat('yyyy-MM').format(DateTime.now());
    List<Map<String, dynamic>> monthlyOrders =
        _orders.where((order) => order['date'].startsWith(currentMonth)).toList();

    return _calculateSummary(monthlyOrders);
  }

  // ✅ ดึงข้อมูลรายปี
  Map<String, dynamic> getYearlySummary() {
    String currentYear = DateFormat('yyyy').format(DateTime.now());
    List<Map<String, dynamic>> yearlyOrders =
        _orders.where((order) => order['date'].startsWith(currentYear)).toList();

    return _calculateSummary(yearlyOrders);
  }

  // ✅ ดึงยอดขายรวมทั้งหมด
  Map<String, dynamic> getTotalSummary() {
    return _calculateSummary(_orders);
  }

  // ฟังก์ชันช่วยคำนวณยอดรวม
  Map<String, dynamic> _calculateSummary(List<Map<String, dynamic>> orders) {
    int totalOrders = 0;
    int totalItemsSold = 0;
    double totalRevenue = 0.0;
    Map<String, int> itemsCount = {}; // นับจำนวนสินค้าทั้งหมด
    Map<String, String> itemsDate = {}; // เก็บวันที่ของสินค้า
    double totalRating = 0.0; // คะแนนรวมทั้งหมด
    int totalRatings = 0; // จำนวนการให้คะแนน

    for (var order in orders) {
      totalOrders++;
      totalRevenue += order['total'];

      String orderDate = order['date'];

      // บวกคะแนนรีวิว
      totalRating += order['rating'];
      totalRatings++;

      for (var itemMap in order['items']) {
        final MenuItem item = MenuItem.fromMap(itemMap);
        totalItemsSold++;

        itemsCount[item.name] = (itemsCount[item.name] ?? 0) + 1;
        itemsDate[item.name] = orderDate; // เก็บวันที่ขายล่าสุดของสินค้า
      }
    }

    double averageRating = totalRatings > 0 ? totalRating / totalRatings : 0.0;

    return {
      'totalOrders': totalOrders,
      'totalItemsSold': totalItemsSold,
      'totalRevenue': totalRevenue,
      'itemsCount': itemsCount,
      'itemsDate': itemsDate,
      'averageRating': averageRating, // เพิ่มการคำนวณคะแนนเฉลี่ย
    };
  }
}
