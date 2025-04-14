import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';

void main() {
  runApp(const CalcyApp());
}

class CalcyApp extends StatelessWidget {
  const CalcyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Calcy',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const CalculatorHomePage(),
    );
  }
}

class CalculatorHomePage extends StatefulWidget {
  const CalculatorHomePage({super.key});

  @override
  State<CalculatorHomePage> createState() => _CalculatorHomePageState();
}

class _CalculatorHomePageState extends State<CalculatorHomePage> {
  String _history = '';
  String _expression = '';

  void _buttonPressed(String buttonText) {
    setState(() {
      if (buttonText == 'AC') {
        _history = '';
        _expression = '';
      } else if (buttonText == 'DEL') {
        if (_expression.isNotEmpty) {
          _expression = _expression.substring(0, _expression.length - 1);
        }
      } else if (buttonText == '+/-') {
        // Basic +/- toggle for the last number - more complex logic might be needed
        if (_expression.isNotEmpty) {
          // This is a simplified implementation. A robust one would parse the expression.
          // For now, let's just toggle if the expression itself is a number.
          try {
            double num = double.parse(_expression);
            _expression = (-num).toString();
            // Remove trailing .0 if it's an integer
            if (_expression.endsWith('.0')) {
              _expression = _expression.substring(0, _expression.length - 2);
            }
          } catch (e) {
            // Handle cases where expression is not just a number or already has operators
            // Might need a more sophisticated parser for full +/- functionality mid-expression
            print("Error toggling sign: $e");
          }
        }
      } else if (buttonText == '=') {
        _history = _expression;
        try {
          // Use math_expressions package to evaluate
          String expressionToParse = _expression;
          // Replace visual operators with ones the parser understands
          expressionToParse = expressionToParse.replaceAll('×', '*');
          expressionToParse = expressionToParse.replaceAll('÷', '/');
          expressionToParse = expressionToParse.replaceAll(
            '%',
            '/100',
          ); // Handle %

          Parser p = Parser();
          Expression exp = p.parse(expressionToParse);
          ContextModel cm = ContextModel();
          double eval = exp.evaluate(EvaluationType.REAL, cm);

          _expression = eval.toString();
          // Remove trailing .0 if it's an integer
          if (_expression.endsWith('.0')) {
            _expression = _expression.substring(0, _expression.length - 2);
          }
        } catch (e) {
          _expression = 'Error';
          print("Calculation Error: $e");
        }
      } else if (buttonText == '%') {
        if (_expression.isNotEmpty) {
          // Append '/100' conceptually, or handle based on context
          // Simple approach: treat '%' as immediate operation on the current number
          try {
            Parser p = Parser();
            // Evaluate the current expression first if needed, or just the last number
            // For simplicity, let's assume '%' applies to the whole current expression
            Expression exp = p.parse(_expression);
            ContextModel cm = ContextModel();
            double currentValue = exp.evaluate(EvaluationType.REAL, cm);
            _expression = (currentValue / 100).toString();
            if (_expression.endsWith('.0')) {
              _expression = _expression.substring(0, _expression.length - 2);
            }
          } catch (e) {
            _expression = 'Error'; // Or handle differently
            print("Percentage Error: $e");
          }
        }
      } else {
        // Append number or operator
        // Handle cases like starting with an operator or multiple operators (basic validation)
        if (_expression == 'Error')
          _expression = ''; // Clear error on new input
        _expression += buttonText;
      }
    });
  }

  Widget _buildButton(String buttonText, Color textColor, Color buttonColor) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(4.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            foregroundColor: textColor,
            backgroundColor: buttonColor, // Text color
            padding: const EdgeInsets.all(20.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0), // Softer corners
            ),
            textStyle: const TextStyle(
              fontSize: 24.0, // Larger font size
              fontWeight: FontWeight.w500,
            ),
          ),
          onPressed: () => _buttonPressed(buttonText),
          child: Text(buttonText),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Dark background
      appBar: AppBar(
        title: const Text('Calcy', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        elevation: 0, // No shadow
      ),
      body: Column(
        children: <Widget>[
          // Display Area
          Expanded(
            flex: 2, // Give more space to display
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 30.0,
              ),
              alignment: Alignment.bottomRight,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // History Display (Optional)
                  Text(
                    _history,
                    style: const TextStyle(
                      fontSize: 20.0,
                      color: Colors.white54,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  // Main Expression Display
                  Text(
                    _expression.isEmpty ? '0' : _expression,
                    style: const TextStyle(
                      fontSize: 48.0,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2, // Allow wrapping slightly
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
          // Button Area
          Expanded(
            flex: 4, // Give more space to buttons
            child: Container(
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  // Row 1
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        _buildButton('AC', Colors.black, Colors.grey), // Clear
                        _buildButton(
                          'DEL',
                          Colors.black,
                          Colors.grey,
                        ), // Backspace
                        _buildButton(
                          '%',
                          Colors.black,
                          Colors.grey,
                        ), // Percentage
                        _buildButton(
                          '÷',
                          Colors.white,
                          Colors.orange,
                        ), // Divide
                      ],
                    ),
                  ),
                  // Row 2
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        _buildButton(
                          '7',
                          Colors.white,
                          Colors.blueGrey.shade800,
                        ),
                        _buildButton(
                          '8',
                          Colors.white,
                          Colors.blueGrey.shade800,
                        ),
                        _buildButton(
                          '9',
                          Colors.white,
                          Colors.blueGrey.shade800,
                        ),
                        _buildButton(
                          '×',
                          Colors.white,
                          Colors.orange,
                        ), // Multiply
                      ],
                    ),
                  ),
                  // Row 3
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        _buildButton(
                          '4',
                          Colors.white,
                          Colors.blueGrey.shade800,
                        ),
                        _buildButton(
                          '5',
                          Colors.white,
                          Colors.blueGrey.shade800,
                        ),
                        _buildButton(
                          '6',
                          Colors.white,
                          Colors.blueGrey.shade800,
                        ),
                        _buildButton(
                          '-',
                          Colors.white,
                          Colors.orange,
                        ), // Subtract
                      ],
                    ),
                  ),
                  // Row 4
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        _buildButton(
                          '1',
                          Colors.white,
                          Colors.blueGrey.shade800,
                        ),
                        _buildButton(
                          '2',
                          Colors.white,
                          Colors.blueGrey.shade800,
                        ),
                        _buildButton(
                          '3',
                          Colors.white,
                          Colors.blueGrey.shade800,
                        ),
                        _buildButton('+', Colors.white, Colors.orange), // Add
                      ],
                    ),
                  ),
                  // Row 5
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        _buildButton(
                          '+/-',
                          Colors.white,
                          Colors.blueGrey.shade800,
                        ), // Plus/Minus
                        _buildButton(
                          '0',
                          Colors.white,
                          Colors.blueGrey.shade800,
                        ),
                        _buildButton(
                          '.',
                          Colors.white,
                          Colors.blueGrey.shade800,
                        ), // Decimal
                        _buildButton(
                          '=',
                          Colors.white,
                          Colors.orange,
                        ), // Equals
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
