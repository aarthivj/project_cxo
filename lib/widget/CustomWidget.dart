import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:month_year_picker/month_year_picker.dart';

// -------------------- Custom Text Field --------------------
class CustomTextField extends StatelessWidget {
  final String labelText;
  final String? hintText;
  final TextEditingController? controller;
  final bool obscureText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const CustomTextField({
    super.key,
    required this.labelText,
    this.hintText,
    this.controller,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
      ),
      validator: validator,
      style: Theme.of(context).textTheme.bodyMedium,
    );
  }
}

// -------------------- Custom Button --------------------
class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(text),
      ),
    );
  }
}

// -------------------- Custom AppBar --------------------
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Widget? leading; // Single leading widget (optional)
  final List<Widget>? actions; // Optional action buttons

  const CustomAppBar({
    super.key,
    required this.title,
    this.leading,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      leading: leading, // optional leading
      actions: actions, // optional actions
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}


// -------------------- Custom Drawer --------------------


class CustomDrawer extends StatelessWidget {
  final Widget child;
  final String username;

  const CustomDrawer({
    super.key,
    required this.child,
    required this.username,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: const Color(0xFF111827), // Dark background
        child: Column(
          children: [
            // --------- Header (Replaced DrawerHeader) ----------
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              color: const Color(0xFF111827),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Logo + Title
                  SizedBox(
  height: 40, 
  width: double.infinity,// adjust as needed
  child: Image.asset(
    "lib/asset/logo.png", // your logo path
    fit: BoxFit.contain,
  ),
),
                  const SizedBox(height: 12), // smaller gap than before
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.tealAccent,
                        radius: 18,
                        child: Text(
                          username.substring(0, 1).toUpperCase(),
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        username,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const Divider(
              color: Colors.white24,
              height: 1,
              thickness: 0.5,
            ),

            // -------- Drawer Content (scrollable) ----------
            Expanded(
              child: SingleChildScrollView(
                child: child,
              ),
            ),

            // -------- Footer ----------
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                "© 2025 Droidal",
                style: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomDrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const CustomDrawerItem({
    super.key,
    required this.icon,
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected ?  Color(0xFF14B8A6) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          size: 20,
color: isSelected ? const Color.fromARGB(255, 255, 255, 255) : Colors.white70,
        ),
        title: Text(
          
          title,
          style: TextStyle(
             fontSize: 14,
            color: isSelected ? const Color.fromARGB(255, 255, 255, 255) : Colors.white70,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}

class FancyBarChart extends StatelessWidget {
  final String title;
  final List<int> data;
  final List<String> labels;
  final List<List<Color>> gradientColors;
  final double maxY;
  final double elevation; // NEW optional parameter

  const FancyBarChart({
    super.key,
    required this.title,
    required this.data,
    required this.labels,
    required this.gradientColors,
    this.maxY = 20,
    this.elevation = 0, // default 0
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Card(
      elevation: elevation, // use the parameter
      shadowColor: Colors.blueAccent.withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: screenWidth * 0.045,
                color: Colors.blueGrey.shade800,
              ),
            ),
            SizedBox(height: screenHeight * 0.02),

            // Chart
            SizedBox(
              height: screenHeight * 0.3,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: maxY,
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              labels[value.toInt() % labels.length],
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  barGroups: _buildBarGroups(),
                ),
                swapAnimationDuration: const Duration(milliseconds: 1200),
                swapAnimationCurve: Curves.easeOutQuart,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<BarChartGroupData> _buildBarGroups() {
    return List.generate(data.length, (index) {
      final colors = gradientColors[index % gradientColors.length];
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: data[index].toDouble(),
            width: 18,
            borderRadius: BorderRadius.circular(8),
            gradient: LinearGradient(
              colors: colors,
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: maxY,
              color: Colors.grey.shade200,
            ),
          ),
        ],
      );
    });
  }
}




class FancyLineChart extends StatelessWidget {
  final String title;
  final List<double> data;
  final List<String> labels;
  final Color gradientStart;
  final Color gradientEnd;

  const FancyLineChart({
    super.key,
    required this.title,
    required this.data,
    required this.labels,
    required this.gradientStart,
    required this.gradientEnd,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      shadowColor: gradientEnd.withOpacity(0.2),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Row(
              children: [
                Icon(Icons.abc),
                 Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: screenWidth * 0.045,
                color: Colors.blueGrey.shade800,
              ),
            ),
              ],
            ),
           
            SizedBox(height: screenHeight * 0.02),
            SizedBox(
              height: screenHeight * 0.3,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: Colors.grey.shade200,
                      strokeWidth: 1,
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= 0 &&
                              value.toInt() < labels.length) {
                            return Text(
                              labels[value.toInt()],
                              style: const TextStyle(fontSize: 12),
                            );
                          }
                          return const SizedBox();
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: List.generate(
                        data.length,
                        (index) => FlSpot(index.toDouble(), data[index]),
                      ),
                      isCurved: true,
                      gradient: LinearGradient(
                        colors: [gradientStart, gradientEnd],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      barWidth: 4,
                      isStrokeCapRound: true,
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            gradientStart.withOpacity(0.3),
                            gradientEnd.withOpacity(0.1),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                      dotData: FlDotData(show: true),
                    ),
                  ],
                ),
               duration: const Duration(milliseconds: 1200),
    curve: Curves.easeOutCubic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class ReusableLineChart extends StatelessWidget {
  final List<double> data; // Y-axis values
  final List<String> labels; // X-axis labels
  final String title;
  final Color startColor;
  final Color endColor;
  final double labelWidth; 

  final double END_PADDING_SPACE = 0.5; 
  final double VERTICAL_RESERVED_SPACE = 0.0; 

  const ReusableLineChart({
    super.key,
    required this.data,
    required this.labels,
    this.title = "",
    this.startColor = Colors.lightBlueAccent,
    this.endColor = Colors.blue,
    this.labelWidth = 100.0, 
  });

  double get maxChartY {
    if (data.isEmpty) return 10.0;
    final double maxValue = data.reduce(max);
    return (maxValue * 1.2).ceilToDouble(); 
  }

  double getYInterval(double maxY) {
    return maxY / 4;
  }
  
  Widget getFormattedYTitle(double value, double maxValue) {
    String text;
    double divisor;
    String suffix;

    if (maxValue >= 1000000000) {
      divisor = 1000000000;
      suffix = 'B';
    } else if (maxValue >= 1000000) {
      divisor = 1000000;
      suffix = 'M';
    } else if (maxValue >= 1000) {
      divisor = 1000;
      suffix = 'K';
    } else {
      divisor = 1;
      suffix = '';
    }

    if (divisor > 1) {
      double scaledValue = value / divisor;
      text = (scaledValue % 1 == 0) ? scaledValue.toInt().toString() : scaledValue.toStringAsFixed(1);
      text = value == 0 ? '0$suffix' : '$text$suffix';
    } else {
      text = value.toInt().toString();
    }
    
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        color: Colors.black,
      ),
      textAlign: TextAlign.left,
    );
  }

  @override
  Widget build(BuildContext context) {
    final double maxYValue = maxChartY;
    final double screenWidth = MediaQuery.of(context).size.width;
    final double actualMaxValue = data.isEmpty ? 0 : data.reduce(max); 

    final double maxChartX = data.isEmpty 
        ? 0 
        : (data.length - 1).toDouble() + END_PADDING_SPACE;

    final double requiredWidth = labels.length * labelWidth + (labelWidth * END_PADDING_SPACE);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Text(
              title,
              style: TextStyle(
                fontSize: screenWidth * 0.045,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey.shade800,
              ),
            ),
          ),
        
        Expanded(
          // **FIX FOR TOP (Y-AXIS) CLIPPING:** Add top padding
          child: Padding(
            padding: const EdgeInsets.only(top: 12.0, right: 8.0), 
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: max(screenWidth - 24 - 8.0, requiredWidth), // Subtract the right padding from the min width
                child: LineChart(
                  LineChartData(
                    minX: 0,
                    maxX: maxChartX,
                    minY: 0,
                    maxY: maxYValue,

                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false, 
                      getDrawingHorizontalLine: (value) {
                        return FlLine(
                          color: Colors.grey.withOpacity(0.3),
                          strokeWidth: 1,
                          dashArray: [5, 5], 
                        );
                      },
                    ),
                    
                    borderData: FlBorderData(
                      show: true,
                      border: Border.all(color: Colors.grey.shade400, width: 1),
                    ),

                    titlesData: FlTitlesData(
                      show: true,
                      // **FIX FOR TOP (Y-AXIS) CLIPPING:** Explicitly hide top titles AND ensure they don't reserve space
topTitles: AxisTitles(
    sideTitles: SideTitles(
        showTitles: false,
        reservedSize: VERTICAL_RESERVED_SPACE // This creates vertical padding
    )
),                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),

                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 70, 
                          interval: 1, 
                          getTitlesWidget: (value, meta) {
                            int index = value.toInt();
                            if (index >= 0 && index < labels.length) {
                              return SideTitleWidget(
                                axisSide: meta.axisSide,
                                space: 4, 
                                child: SizedBox(
                                  width: labelWidth * 0.8, 
                                  child: Text(
                                    labels[index],
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black,
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 3, 
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              );
                            }
                            return const SizedBox();
                          },
                        ),
                      ),

                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          interval: getYInterval(maxYValue), 
                          getTitlesWidget: (value, meta) {
                            return getFormattedYTitle(value, actualMaxValue);
                          },
                        ),
                      ),
                    ),

                    lineBarsData: [
                      LineChartBarData(
                        spots: List.generate(
                          data.length,
                          (index) => FlSpot(index.toDouble(), data[index]),
                        ),
                        isCurved: true, 
                        barWidth: 3,
                        gradient: LinearGradient(
                          colors: [startColor, endColor],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                        dotData: FlDotData(show: true), 
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}


// --- Multi-Line Chart Widget ---
class MultiLineChart extends StatelessWidget {
  final List<double> data1; // e.g., Onboarded Counts
  final List<double> data2; // e.g., Debarred Counts
  final List<String> labels; // X-axis labels (e.g., Jan, Feb, Mar)
  final Color color1;
  final Color color2;
  final double labelWidth; 

  // Constants for fixing clipping
  final double END_PADDING_SPACE = 1.0; // Pushes chart data point 1 interval to the right
  final double VERTICAL_RESERVED_SPACE = 20.0; // Reserves space at the top of the chart
  final double LABEL_RESERVED_HEIGHT = 70.0;
  final double LABEL_RESERVED_WIDTH = 40.0;

  const MultiLineChart({
    super.key,
    required this.data1,
    required this.data2,
    required this.labels,
    this.color1 = Colors.green,
    this.color2 = Colors.red,
    this.labelWidth = 80.0, 
  });

  double get maxChartY {
    List<double> allData = [...data1, ...data2];
    if (allData.isEmpty) return 10.0;
    final double maxValue = allData.reduce(max);
    return (maxValue * 1.2).ceilToDouble(); 
  }

  double getYInterval(double maxY) {
    return maxY / 4;
  }
  
  Widget getFormattedYTitle(double value, double maxValue) {
    String text = value.toInt().toString(); 
    return Text(
      text,
      style: const TextStyle(fontSize: 12, color: Colors.black),
      textAlign: TextAlign.left,
    );
  }

  @override
  Widget build(BuildContext context) {
    final double maxYValue = maxChartY;
    
    // FIX 1 (X-Axis Clipping): Calculate maxX for the chart dots
    final double maxChartX = labels.isEmpty ? 0 : (labels.length - 1).toDouble() + END_PADDING_SPACE;
    // Calculate required width for horizontal scrolling
    final double requiredWidth = labels.length * labelWidth + (labelWidth * END_PADDING_SPACE);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: max(MediaQuery.of(context).size.width - 48, requiredWidth), 
        height: 250, 
        child: LineChart(
          LineChartData(
            minX: 0,
            maxX: maxChartX, // Use the fixed MaxX
            minY: 0,
            maxY: maxYValue,

            titlesData: FlTitlesData(
              show: true,
              // FIX 2 (Y-Axis Clipping): Add reserved space to the top titles (which are hidden)
              topTitles: AxisTitles(
                  sideTitles: SideTitles(
                      showTitles: false,
                      reservedSize: VERTICAL_RESERVED_SPACE // Creates vertical padding at the top
                  )
              ),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),

              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: LABEL_RESERVED_HEIGHT, 
                  interval: 1, 
                  getTitlesWidget: (value, meta) {
                    int index = value.toInt();
                    if (index >= 0 && index < labels.length) {
                      return SideTitleWidget(
                        axisSide: meta.axisSide,
                        space: 4, 
                        child: Text(labels[index], style: const TextStyle(fontSize: 10)),
                      );
                    }
                    return const SizedBox();
                  },
                ),
              ),

              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: LABEL_RESERVED_WIDTH,
                  interval: getYInterval(maxYValue), 
                  getTitlesWidget: (value, meta) {
                    return getFormattedYTitle(value, maxChartY);
                  },
                ),
              ),
            ),
            
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false, 
              getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey.withOpacity(0.3), strokeWidth: 1, dashArray: [5, 5]),
            ),
            borderData: FlBorderData(show: true, border: Border.all(color: Colors.grey.shade400, width: 1)),

            lineBarsData: [
              // Line 1 (Onboarded - Green)
              LineChartBarData(
                spots: List.generate(data1.length, (index) => FlSpot(index.toDouble(), data1[index])),
                isCurved: true, barWidth: 2, dotData: FlDotData(show: true, getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(color: color1, radius: 4)),
                color: color1,
              ),
              // Line 2 (Debarred - Red)
              LineChartBarData(
                spots: List.generate(data2.length, (index) => FlSpot(index.toDouble(), data2[index])),
                isCurved: true, barWidth: 2, dotData: FlDotData(show: true, getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(color: color2, radius: 4, strokeColor: Colors.transparent)),
                color: color2,
              ),
            ],
          ),
        ),
      ),
    );
  }
}