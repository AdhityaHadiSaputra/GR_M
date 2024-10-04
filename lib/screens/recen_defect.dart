import 'package:flutter/material.dart';
import 'package:grmobile/drawer.dart';
import 'package:grmobile/models/db_helper.dart';
import 'package:grmobile/screens/detail/recent_po_defect.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RecentDefectPOPage extends StatefulWidget {
  const RecentDefectPOPage({super.key});

  @override
  _RecentDefectPOPageState createState() => _RecentDefectPOPageState();
}

class _RecentDefectPOPageState extends State<RecentDefectPOPage> {
  final DatabaseHelper dbHelper = DatabaseHelper();
  List<String> recentNoPOs = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchRecentPO(); // Fetch recent POs when the page loads
  }

  Future<void> fetchRecentPO() async {
    final prefs = await SharedPreferences.getInstance();
    recentNoPOs = prefs.getStringList('recent_pos_defect') ?? [];
    setState(() {
      isLoading = false;
    });
  }

  Future<void> removeRecentPO(String poNumber) async {
    final prefs = await SharedPreferences.getInstance();
    recentNoPOs.remove(poNumber);
    await prefs.setStringList('recent_pos_defect', recentNoPOs);

    // Remove PO from the database
    await dbHelper.deleteDefectPOResult(poNumber);

    setState(() {}); // Update the UI
  }

  // Method to clear all defect records
  Future<void> clearAllDefects() async {
    await dbHelper.clearDefectTable();
    setState(() {
      recentNoPOs.clear(); // Clear the local list
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('All defect records deleted')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recent PO Defect'),

      ),
      drawer: const MyDrawer(),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : recentNoPOs.isEmpty
          ? const Center(child: Text('No recent PO found'))
          : ListView.builder(
        itemCount: recentNoPOs.length,
        itemBuilder: (context, index) {
          final poNumber = recentNoPOs[index];
          return Card(
            margin: const EdgeInsets.all(8.0),
            child: ListTile(
              title: Text(poNumber),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              PODefectPage(poNumber: poNumber),
                        ),
                      );
                    },
                    child: const Column(
                      children: [
                        Icon(Icons.view_cozy),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  TextButton(
                    onPressed: () {
                      // Remove the PO from the list and update SharedPreferences and database
                      clearAllDefects();
                    },
                    child: const Column(
                      children: [
                        Icon(Icons.delete),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
