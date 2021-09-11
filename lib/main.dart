import 'dart:async';
import 'dart:core';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart';
import 'package:flutter/services.dart' show ByteData, rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:flutter_barcode_listener/flutter_barcode_listener.dart';



String path = 'No Path';
void main() async {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Clarel',
      theme: ThemeData(
        fontFamily: 'Product Sans',
        primarySwatch: Colors.deepPurple,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> _allProducts = [];
  List<Map<String, dynamic>> _foundProduct = [];
  final globalKey = GlobalKey<ScaffoldState>();
  var excelDB;
  var excel;
  late Sheet sheetObject;
  late Timer _debounce;
  String? _barcode;
  String filter='';

  @override
  initState(){
    cargarDB();
    loadCsvFromStorage();
      _foundProduct = _allProducts;
      print('InitState');
    super.initState();
  }
  @override
  void dispose() {
    _debounce.cancel();

    super.dispose();
  }
  _onSearchChanged(String value) {
      _debounce = Timer(const Duration(milliseconds: 200), () {
      _runFilter(value);
    });
  }
  void cargarDB() async{
    ByteData data = await rootBundle.load("assets/dbProducts.xlsx");
    var bytesDB = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    excelDB = Excel.decodeBytes(bytesDB);

  }

  loadCsvFromStorage() async {
    print('loadCsvFromStorage');
      await Future.delayed(Duration(seconds: 5));
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowedExtensions: ['xlsx'],
      type: FileType.custom,
    );
    if (result != null) {
      setState(() {
        path = result.files.first.path!;
      });
    }
    var file = path;
    print(path);
    var bytes = File(file).readAsBytesSync();
    excel = Excel.decodeBytes(bytes);
    sheetObject=excel['Sheet1'];
    for (var table in excel.tables.keys) {
      print(table);
      print(excel.tables[table]!.maxCols);
      print(excel.tables[table]!.maxRows);
      for (var row in excel.tables[table]!.rows) {
        setState(() {
          _allProducts.add(
              {"codigo": row[0], "descripcion": row[1], "unidades": row[2]});
        });
      }
    }
  }

  void _runFilter(String enteredKeyword) {

    List<Map<String, dynamic>> results = [];


    if (enteredKeyword.isEmpty) {
      results = _allProducts;
    } else {
      if (enteredKeyword.length >=8){
        if (enteredKeyword != null && enteredKeyword.length > 0) {
          enteredKeyword = enteredKeyword.substring(0, enteredKeyword.length - 1);
        }
        for (var table in excelDB.tables.keys) {
          for (var row in excelDB.tables[table].rows) {
            if (row[1].toString()==enteredKeyword){
              filter=row[0].toString();
            }
          }
        }
      }else{
          filter=enteredKeyword;
      }
      results = _allProducts.where((user) => user["codigo"].toString().contains(filter,0))
          .toList();
          }


    setState(() {
      _foundProduct = results;
    });

    Future.delayed(const Duration(seconds: 2), () {
saveExcel();

    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: globalKey,
      appBar: AppBar(
        title: Text('CheckProvision'),
      ),
      body: BarcodeKeyboardListener(
        onBarcodeScanned: (barcode) {
          print(barcode);
          setState(() {
            _barcode = barcode;
            _runFilter(_barcode!);
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              SizedBox(
                height: 20,
              ),
              TextField(
                onChanged: (value) => _onSearchChanged(value),
                decoration: InputDecoration(
                    labelText: 'Buscar', suffixIcon: Icon(Icons.search)),
              ),
              SizedBox(
                height: 20,
              ),
              Expanded(
                child: _foundProduct.length > 0
                    ? RefreshIndicator(
                      child: ListView.builder(
                          itemCount: _foundProduct.length,
                          itemBuilder: (context, index) => Dismissible(
                            background: stackBehindDismiss(),
                            key: ObjectKey(_foundProduct[index]),
                            child: Card(
                              key: ValueKey(_foundProduct[index]["codigo"]),
                              color: Colors.amberAccent,
                              elevation: 4,
                              margin: EdgeInsets.symmetric(vertical: 10),
                              child: ListTile(
                                leading: Text(
                                  _foundProduct[index]["unidades"].toString(),
                                  style: TextStyle(fontSize: 35),
                                ),
                                title: Text(_foundProduct[index]['descripcion']),
                                subtitle: Text(
                                    '${_foundProduct[index]["codigo"].toString()}',style: TextStyle(fontSize: 15)),
                              ),
                            ),
                            onDismissed: (direction) {
                              var item = _foundProduct.elementAt(index);
                              print(item);
                              //To delete
                              deleteItem(item,index);
                              
                              final snackBar = SnackBar(
                                  content: Text("Producto correcto"),
                                  action: SnackBarAction(
                                    label: "DESHACER",
                                    onPressed: () {
                                      undoDeletion(index, item);
                                    },
                                  ));
                              globalKey.currentState!.showSnackBar(snackBar);
                            },
                          ),
                        ),onRefresh: _getData,
                    )
                    : Text(
                        'No hay resultados',
                        style: TextStyle(fontSize: 24),
                      ),
              ),
            ],
          ),
        ),
      ),      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.save),
        onPressed: () => {
          //do something
          saveExcel()
        }),
    );
  }

  Future<void> _getData() async {
    setState(() {
      _foundProduct=_allProducts;
    });
  }
saveExcel()async{
  await Future.delayed(Duration(seconds: 5));
  String directory = (await getExternalStorageDirectory())!.path;
  excel.encode().then((onValue) {
  File(join("${directory}/Suministro_Guardado_${DateTime.now().day}-${DateTime.now().month}_${DateTime.now().hour}.${DateTime.now().minute}.${DateTime.now().second}.xlsx"))
  ..createSync(recursive: true)
  ..writeAsBytesSync(onValue);
  });
}
  void deleteItem(item,index) {
     setState(() {
      _allProducts.remove(item);
      sheetObject.removeRow(index);
      _foundProduct=_allProducts;
       filter="";
      saveExcel();
    });
  }

  void undoDeletion(index, item) {
    setState(() {
      _allProducts.add(item);
      _foundProduct=_allProducts;
      saveExcel();
    });
  }

  Widget stackBehindDismiss() {
    return Container(
      alignment: Alignment.centerRight,
      padding: EdgeInsets.only(right: 20.0),
      color: Colors.green,
      child: Icon(
        Icons.check,
        color: Colors.white,
      ),
    );
  }
}
