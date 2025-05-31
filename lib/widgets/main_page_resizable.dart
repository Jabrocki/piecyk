import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:piecyk/widgets/circular_chart.dart'; // Import the circular chart

class MainPageResizableVertical extends StatelessWidget {
  
  
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      border: Border.all(color: context.theme.colors.border),
      borderRadius: BorderRadius.circular(8),
    ),
    child: FResizable(
      axis: Axis.vertical,
      controller: FResizableController(),
      crossAxisExtent: (MediaQuery.sizeOf(context).width)/3,
      children: [
        FResizableRegion(
          initialExtent: (MediaQuery.sizeOf(context).height) * (1/3),
          minExtent: 100,
          builder: (_, data, __) => Text('SUNSEER'),
        ),
        FResizableRegion(
          initialExtent: 180,
          minExtent: 180,
          builder: (_, layoutData, __) => Padding( // Added Padding
            padding: const EdgeInsets.all(8.0), // Added padding value
            child: Row(
              children: <Widget>[
                Expanded(
                  child: CircularChart( 
                    data: [
                      ChartData(value: 30, color: const Color.fromARGB(255, 0, 255, 55), label: 'Data A'),
                      ChartData(value: 50, color: const Color.fromARGB(255, 0, 203, 7), label: 'Data B'),
                      ChartData(value: 10, color: const Color.fromARGB(255, 0, 129, 6), label: 'Data C'),
                      ChartData(value: 10, color: const Color.fromARGB(255, 4, 74, 0), label: "elo")
                    ],
                    holeRadius: layoutData.extent.current * 0.10, 
                  ),
                ),
                Expanded(
                  child: Text('Lmao power goes brr', textAlign: TextAlign.center),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

