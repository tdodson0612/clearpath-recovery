import 'package:flutter/material.dart';
import 'dart:async';

class PanicButtonPage extends StatefulWidget {
  const PanicButtonPage({super.key});

  @override
  State<PanicButtonPage> createState() => _PanicButtonPageState();
}

class _PanicButtonPageState extends State<PanicButtonPage> {
  int _currentExercise = 0;
  bool _isBreathing = false;
  Timer? _breathTimer;
  String _breathPhase = 'Breathe In';
  int _breathCount = 0;

  final List<Map<String, dynamic>> _exercises = [
    {
      'title': '5-4-3-2-1 Grounding',
      'description': 'Use your senses to anchor yourself in the present moment',
      'steps': [
        '5 things you can SEE around you',
        '4 things you can TOUCH',
        '3 things you can HEAR',
        '2 things you can SMELL',
        '1 thing you can TASTE',
      ],
      'icon': Icons.visibility,
    },
    {
      'title': 'Box Breathing',
      'description': 'Regulated breathing to calm your nervous system',
      'steps': [
        'Breathe in for 4 seconds',
        'Hold for 4 seconds',
        'Breathe out for 4 seconds',
        'Hold for 4 seconds',
        'Repeat 4 times',
      ],
      'icon': Icons.air,
    },
    {
      'title': 'Cold Water Splash',
      'description': 'Physical reset for your nervous system',
      'steps': [
        'Go to the nearest sink',
        'Splash cold water on your face',
        'Hold a cold compress to your forehead',
        'Focus on the sensation',
        'Take slow, deep breaths',
      ],
      'icon': Icons.water_drop,
    },
    {
      'title': 'Safe Place Visualization',
      'description': 'Imagine yourself in a calm, safe environment',
      'steps': [
        'Close your eyes if comfortable',
        'Picture a place where you feel safe',
        'Notice the details: colors, sounds, smells',
        'Feel yourself there',
        'Stay as long as you need',
      ],
      'icon': Icons.landscape,
    },
  ];

  @override
  void dispose() {
    _breathTimer?.cancel();
    super.dispose();
  }

  void _startBreathing() {
    setState(() {
      _isBreathing = true;
      _breathCount = 0;
    });

    const phases = ['Breathe In', 'Hold', 'Breathe Out', 'Hold'];
    int phaseIndex = 0;

    _breathTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_breathCount >= 16) { // 4 complete cycles
        _stopBreathing();
        return;
      }

      setState(() {
        phaseIndex = (_breathCount % 4);
        _breathPhase = phases[phaseIndex];
        _breathCount++;
      });
    });
  }

  void _stopBreathing() {
    _breathTimer?.cancel();
    setState(() {
      _isBreathing = false;
      _breathCount = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final exercise = _exercises[_currentExercise];

    return Scaffold(
      backgroundColor: const Color(0xFFFEF2F2),
      appBar: AppBar(
        backgroundColor: const Color(0xFFDC2626),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Panic Button',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          // Emergency header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            color: const Color(0xFFDC2626),
            child: Column(
              children: [
                const Icon(
                  Icons.emergency,
                  color: Colors.white,
                  size: 48,
                ),
                const SizedBox(height: 12),
                const Text(
                  'You\'re Safe',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'This feeling will pass. Let\'s get through this together.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),

          // Exercise selector
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(_exercises.length, (index) {
                  final isSelected = index == _currentExercise;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(_exercises[index]['title']),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _currentExercise = index;
                            _stopBreathing();
                          });
                        }
                      },
                      selectedColor: const Color(0xFFDC2626),
                      backgroundColor: const Color(0xFFF3F4F6),
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : const Color(0xFF6B7280),
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),

          // Exercise content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Exercise card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEF2F2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                exercise['icon'] as IconData,
                                color: const Color(0xFFDC2626),
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    exercise['title'],
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1F2937),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    exercise['description'],
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF6B7280),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Steps
                        ...List.generate(
                          (exercise['steps'] as List).length,
                          (index) => Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFDC2626),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${index + 1}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    exercise['steps'][index],
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Color(0xFF374151),
                                      height: 1.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Breathing animation for box breathing
                        if (_currentExercise == 1) ...[
                          const SizedBox(height: 24),
                          Center(
                            child: Column(
                              children: [
                                if (_isBreathing)
                                  AnimatedContainer(
                                    duration: const Duration(seconds: 4),
                                    width: _breathPhase == 'Breathe In' || _breathPhase == 'Hold' && _breathCount % 2 == 1 ? 120 : 80,
                                    height: _breathPhase == 'Breathe In' || _breathPhase == 'Hold' && _breathCount % 2 == 1 ? 120 : 80,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFDC2626).withOpacity(0.2),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: const Color(0xFFDC2626),
                                        width: 3,
                                      ),
                                    ),
                                  ),
                                const SizedBox(height: 16),
                                Text(
                                  _isBreathing ? _breathPhase : 'Ready to begin',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1F2937),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                ElevatedButton(
                                  onPressed: _isBreathing ? _stopBreathing : _startBreathing,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFDC2626),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 32,
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: Text(
                                    _isBreathing ? 'Stop' : 'Start Breathing Exercise',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Emergency contact reminder
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.phone,
                          color: Color(0xFFDC2626),
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Still in crisis?',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1F2937),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Call 988 or 911 immediately',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
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