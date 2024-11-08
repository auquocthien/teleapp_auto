import 'package:flutter/material.dart';
import 'package:flutter_auto_tele/models/tele_app.dart';
import 'package:flutter_auto_tele/ui/tele_app/tele_app_item.dart';
import 'package:flutter_auto_tele/ui/tele_app/tele_app_manager.dart';
import 'package:provider/provider.dart';

class Cells extends StatefulWidget {
  const Cells({super.key});

  @override
  State<Cells> createState() => _CellsState();
}

class _CellsState extends State<Cells> {
  @override
  void initState() {
    super.initState();
    // Gọi hàm getTeleApp() để tải danh sách ứng dụng mở khi widget được khởi tạo
    context.read<TeleAppManager>().getTeleApp();
  }

  @override
  Widget build(BuildContext context) {
    // Lấy danh sách teleApps từ TeleAppManager
    List<TeleApp> apps = context.watch<TeleAppManager>().teleApps;

    if (apps.isEmpty) {
      return const Center(
        child:
            CircularProgressIndicator(), // Hiển thị loading khi chưa có dữ liệu
      );
    }

    return GridView.builder(
      itemCount: apps.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.705,
      ),
      itemBuilder: (BuildContext context, int index) {
        return CellItem(apps[index]); // Tạo widget cho mỗi item
      },
      scrollDirection: Axis.vertical,
    );
  }
}
