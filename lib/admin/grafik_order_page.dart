import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BarangKeluarChartPage extends StatefulWidget {
  const BarangKeluarChartPage({Key? key}) : super(key: key);

  @override
  _BarangKeluarChartPageState createState() => _BarangKeluarChartPageState();
}

class _BarangKeluarChartPageState extends State<BarangKeluarChartPage> {
  Map<String, int> barangKeluarData = {};

  @override
  void initState() {
    super.initState();
    _fetchBarangKeluarData();
  }

  Future<void> _fetchBarangKeluarData() async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('barang_keluar').get();

      Map<String, int> tempData = {};

      for (var doc in snapshot.docs) {
        String namaBarang = doc['nama_barang'];
        int jumlah = doc['jumlah'];

        if (tempData.containsKey(namaBarang)) {
          tempData[namaBarang] = tempData[namaBarang]! + jumlah;
        } else {
          tempData[namaBarang] = jumlah;
        }
      }

      setState(() {
        barangKeluarData = tempData;
      });
    } catch (e) {
      print('Error fetching barang keluar data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Grafik Barang Keluar',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 44, 179, 190),
                Color.fromARGB(255, 27, 52, 71),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 44, 179, 190),
              Color.fromARGB(255, 27, 52, 71),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: barangKeluarData.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      'Grafik Barang Keluar',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: CustomPaint(
                        painter: BarChartPainter(barangKeluarData),
                        child: Container(),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class BarChartPainter extends CustomPainter {
  final Map<String, int> data;

  BarChartPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    final double marginLeft = 50.0; // Margin untuk sumbu Y
    final double marginBottom = 40.0; // Margin untuk sumbu X
    final double barSpacing = 15.0; // Jarak antar batang
    final double barWidth =
        (size.width - marginLeft) / data.length - barSpacing;
    final double maxDataValue =
        data.values.reduce((a, b) => a > b ? a : b).toDouble();

    // Menentukan interval sumbu Y dinamis
    final int stepY = maxDataValue <= 5
        ? 1
        : maxDataValue <= 20
            ? 2
            : maxDataValue <= 100
                ? 10
                : 50;

    final Paint paint = Paint()
      ..shader = const LinearGradient(
        colors: [
          Color.fromARGB(255, 243, 246, 246),
          Color.fromARGB(255, 212, 230, 245),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, barWidth, size.height));

    // Skala untuk sumbu Y
    final double scaleY = (size.height - marginBottom) / (maxDataValue + stepY);

    // Gambar garis sumbu Y dan angka
    final Paint axisPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1;

    for (int i = 0; i <= maxDataValue + stepY; i += stepY) {
      final double yPosition = size.height - marginBottom - (i * scaleY);
      canvas.drawLine(
        Offset(marginLeft, yPosition),
        Offset(size.width, yPosition),
        axisPaint,
      );

      final TextPainter textPainter = TextPainter(
        text: TextSpan(
          text: '$i',
          style: const TextStyle(color: Colors.white, fontSize: 15),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(marginLeft - 40, yPosition - 6));
    }

    // Gambar batang
    int index = 0;
    data.forEach((key, value) {
      final double barHeight = value * scaleY;
      final double xPosition = marginLeft + (index * (barWidth + barSpacing));

      final Rect barRect = Rect.fromLTWH(
        xPosition,
        size.height - marginBottom - barHeight,
        barWidth,
        barHeight,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(barRect, const Radius.circular(5.0)),
        paint,
      );

      // Gambar teks nama barang pada sumbu X
      final TextPainter textPainter = TextPainter(
        text: TextSpan(
          text: key,
          style: const TextStyle(color: Colors.white, fontSize: 15),
        ),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      );
      textPainter.layout(maxWidth: barWidth);
      textPainter.paint(
        canvas,
        Offset(xPosition + barWidth / 2 - textPainter.width / 2,
            size.height - marginBottom + 4),
      );

      index++;
    });
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
