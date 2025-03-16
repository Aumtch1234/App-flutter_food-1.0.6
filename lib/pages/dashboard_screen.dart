import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:project/provider/order_history_provider.dart'; // นำเข้า provider ที่เก็บข้อมูลคำสั่งซื้อ

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _selectedPeriod = 'รายวัน'; // ค่าเริ่มต้น
  Map<String, dynamic> summaryData = {};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateSummary();
  }

  void _updateSummary() {
    final orderHistory = Provider.of<OrderHistoryProvider>(context, listen: false);

    setState(() {
      if (_selectedPeriod == 'รายวัน') {
        summaryData = orderHistory.getTodaySummary();
      } else if (_selectedPeriod == 'รายเดือน') {
        summaryData = orderHistory.getMonthlySummary();
      } else if (_selectedPeriod == 'รายปี') {
        summaryData = orderHistory.getYearlySummary();
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard การขาย'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ข้อมูลคำสั่งซื้อในช่วง $_selectedPeriod',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'เลือกช่วงเวลา:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                DropdownButton<String>(
                  value: _selectedPeriod,
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedPeriod = newValue;
                        _updateSummary(); // อัพเดทข้อมูลตามช่วงเวลา
                      });
                    }
                  },
                  items: ['รายวัน', 'รายเดือน', 'รายปี']
                      .map<DropdownMenuItem<String>>(
                        (String value) => DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
            SizedBox(height: 10),
            Text(
              '📊 สรุปยอดขาย ($_selectedPeriod)',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            // ✅ แสดงข้อมูลยอดขาย
            Card(
              color: Colors.green[100],
              child: ListTile(
                title: Text('🛍 จำนวนออเดอร์ทั้งหมด: ${summaryData['totalOrders']} ออเดอร์'),
                subtitle: Text('🥤 จำนวนแก้วที่ขาย: ${summaryData['totalItemsSold']} แก้ว'),
                trailing: Text(
                  '💰 รวมเงิน: ${summaryData['totalRevenue'].toStringAsFixed(2)} บาท',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              '📌 รายการสินค้าที่ขาย:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            // ✅ แสดงรายการสินค้าที่ขาย
            Expanded(
              child: summaryData['itemsCount'].isEmpty
                  ? Center(child: Text("ยังไม่มีรายการขาย $_selectedPeriod"))
                  : ListView(
                      children: summaryData['itemsCount']
                          .entries
                          .map<Widget>((entry) {
                        String itemName = entry.key;
                        String itemDate = summaryData['itemsDate'][itemName] ?? 'ไม่ระบุวันที่'; // ดึงวันที่ของสินค้าจาก itemsDate

                        return ListTile(
                          title: Text(itemName),
                          subtitle: Text('วันที่ขาย: $itemDate'), // แสดงวันที่ที่ขายสินค้า
                          trailing: Text('🛒 ขายได้: ${entry.value} ชิ้น'),
                        );
                      }).toList(),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
