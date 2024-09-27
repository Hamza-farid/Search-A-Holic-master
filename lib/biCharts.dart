import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:searchaholic/sidebar.dart';
import 'imports.dart';

class BiCharts extends StatefulWidget {
  const BiCharts({Key? key}) : super(key: key);

  @override
  _BiChartsState createState() => _BiChartsState();
}

class _BiChartsState extends State<BiCharts> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  Map<DateTime, int> dataMap = {};
  Map<String, int> dailyDataMap = {};
  late List<SalesData> salesData1 = [];
  late List<SalesData> salesData2 = [];
  late List<HotProduct> productCounter = [];

  @override
  void initState() {
    super.initState();
    getHotProduct();
    getData().then((value) {
      setState(() {
        salesData1 = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          const Sidebar(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(8),
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(
                    left: MediaQuery.of(context).size.width * 0.04,
                    right: MediaQuery.of(context).size.width * 0.015,
                  ),
                  child: Column(children: [
                    const Padding(padding: EdgeInsets.only(top: 20)),
                    Padding(
                      padding: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height * 0.057,
                      ),
                      child: Text("Report's",
                          style: TextStyle(
                            fontFamily: "Montserrat",
                            fontWeight: FontWeight.w600,
                            fontSize: MediaQuery.of(context).size.width / 35,
                          )),
                    ),
                  ]),
                ),
                _buildCard("Daily Sales Report", _buildDailySalesChart()),
                _buildCard("Live Sales Report", _buildLiveSalesChart()),
                _buildCard("Hot Product", _buildHotProductChart()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(String title, Widget child) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Card(
          color: Colors.white70,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.only(left: 20),
          child: Column(
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Colors.blue,
                  fontFamily: "Montserrat",
                  fontWeight: FontWeight.w400,
                  fontSize: MediaQuery.of(context).size.width / 40,
                ),
              ),
              child,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDailySalesChart() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.74,
      width: MediaQuery.of(context).size.width * 0.90,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.only(left: 20),
        child: SfCartesianChart(
          title: ChartTitle(text: "Daily Sales"),
          primaryXAxis: CategoryAxis(title: AxisTitle(text: "Sales Date")),
          primaryYAxis: NumericAxis(
            title: AxisTitle(text: "Sale in Rupees"),
            labelFormat: "{value} Rs",
          ),
          series: <CartesianSeries>[
            ColumnSeries<SalesData, String>(
              dataSource: salesData1,
              xValueMapper: (SalesData sales, _) => sales.x,
              yValueMapper: (SalesData sales, _) => sales.y,
              dataLabelSettings: DataLabelSettings(isVisible: true),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLiveSalesChart() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      width: MediaQuery.of(context).size.width * 0.90,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.only(left: 20),
        child: SfCartesianChart(
          title: ChartTitle(text: 'Live Sales'),
          primaryXAxis: CategoryAxis(),
          series: <CartesianSeries>[
            LineSeries<SalesData, String>(
              dataSource: salesData2,
              xValueMapper: (SalesData sales, _) => sales.x,
              yValueMapper: (SalesData sales, _) => sales.y,
              dataLabelSettings: const DataLabelSettings(isVisible: true),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHotProductChart() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.90,
      width: MediaQuery.of(context).size.width * 0.90,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.only(left: 20),
        child: SfCartesianChart(
          title: ChartTitle(text: "Hot Product"),
          primaryXAxis: CategoryAxis(title: AxisTitle(text: "Product Name")),
          primaryYAxis: NumericAxis(
            title: AxisTitle(text: "Hot Product Quantity"),
            labelFormat: "{value} Qty",
          ),
          series: <CartesianSeries>[
            ColumnSeries<HotProduct, String>(
              dataSource: productCounter,
              xValueMapper: (HotProduct product, _) => product.productName,
              yValueMapper: (HotProduct product, _) => product.productCount,
              dataLabelSettings: DataLabelSettings(isVisible: true),
            ),
          ],
        ),
      ),
    );
  }

  Future<List<SalesData>> getData() async {
    var email = await Flutter_api().getEmail();
    var storeId = await Flutter_api().generateStoreId(email);

    // Getting Sales Data
    var salesData = await FirebaseFirestore.instance.collection(storeId).get();

    for (var doc in salesData.docs) {
      dataMap[DateTime.parse(doc['saleDate'])] = doc['saleAmount'];
    }

    List<MapEntry<DateTime, int>> listMappedEntries = dataMap.entries.toList();
    listMappedEntries.sort((a, b) => a.key.compareTo(b.key));

    final Map<DateTime, int> sortedMapData = Map.fromEntries(listMappedEntries);

    for (var i in sortedMapData.keys) {
      var dateKey = DateFormat('yyyy-MM-dd').format(i);
      if (dailyDataMap.containsKey(dateKey)) {
        dailyDataMap[dateKey] = dailyDataMap[dateKey]! + sortedMapData[i]!;
      } else {
        dailyDataMap[dateKey] = sortedMapData[i]!;
      }
    }

    setState(() {
      for (var key in dailyDataMap.keys) {
        salesData1.add(SalesData(key.toString(), dailyDataMap[key]!));
      }
      for (var i in sortedMapData.keys) {
        salesData2.add(SalesData(DateFormat.yMd().add_Hm().format(i), sortedMapData[i]!));
      }
    });

    return salesData1;
  }

  Future<void> getHotProduct() async {
    var storeId = await Flutter_api().generateStoreId(await Flutter_api().getEmail());
    var stores = await FirebaseFirestore.instance.collection(storeId).get();
    Map<String, int> productCounterMap = {};

    for (var store in stores.docs) {
      Map storeProduct = store["saleProducts"];
      for (var product in storeProduct.keys) {
        if (productCounterMap.containsKey(product)) {
          productCounterMap[product] = productCounterMap[product]! + int.parse(storeProduct[product]);
        } else {
          productCounterMap[product] = int.parse(storeProduct[product]);
        }
      }
    }

    setState(() {
      productCounterMap.forEach((key, value) {
        productCounter.add(HotProduct(key, value));
      });
      productCounter.sort((a, b) => b.productCount.compareTo(a.productCount));
      productCounter = productCounter.take(4).toList(); // Top 4 hot products
    });
  }
}

class HotProduct {
  String productName;
  int productCount;

  HotProduct(this.productName, this.productCount);
}

class SalesData {
  String x; // x-axis value (date or year)
  int y;   // y-axis value (amount or count)

  SalesData(this.x, this.y);
}
