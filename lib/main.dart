import 'dart:io';
import 'package:flutter/material.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

void main() {
  runApp(const EarlyBirdApp());
}

class EarlyBirdApp extends StatelessWidget {
  const EarlyBirdApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext WidgetContext) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Early Bird Stock',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const StockHomePage(),
    );
  }
}

class StockHomePage extends StatefulWidget {
  const StockHomePage({Key? key}) : super(key: key);

  @override
  State<StockHomePage> createState() => _StockHomePageState();
}

class _StockHomePageState extends State<StockHomePage> {
  List<List<dynamic>> excelData = [];
  bool isLoading = false;
  final AudioPlayer audioPlayer = AudioPlayer();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Early Bird Stock Management'),
        backgroundColor: Colors.blue,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : excelData.isEmpty
              ? const Center(child: Text('No Data Loaded. Please Import Excel File.'))
              : ListView.builder(
                  itemCount: excelData.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(excelData[index].toString()),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: pickExcelFile,
        child: const Icon(Icons.file_upload),
      ),
    );
  }

  Future<void> pickExcelFile() async {
    setState(() {
      isLoading = true;
    });

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
      );

      if (result != null && result.files.single.path != null) {
        var bytes = File(result.files.single.path!).readAsBytesSync();
        var excel = Excel.decodeBytes(bytes);
        List<List<dynamic>> loadedData = [];

        for (var table in excel.tables.keys) {
          for (var row in excel.tables[table]!.rows) {
            loadedData.add(row.map((cell) => cell?.value).toList());
          }
        }

        setState(() {
          excelData = loadedData;
          isLoading = false;
        });

        await audioPlayer.play(AssetSource('success.mp3'));
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading file: $e')),
      );
    }
  }
}
