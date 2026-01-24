import 'package:flutter/material.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class UrgeTimerPage extends StatefulWidget {
  const UrgeTimerPage({super.key});

  @override
  State<UrgeTimerPage> createState() => _UrgeTimerPageState();
}

class _UrgeTimerPageState extends State<UrgeTimerPage> {
  Timer? _timer;
  int _remainingSeconds = 600;
  int _totalSeconds = 600;
  bool _isRunning = false;
  bool _isComplete = false;
  bool _showIntensityDialog = false;
  
  // Intensity tracking
  int? _initialIntensity;
  int? _finalIntensity;
  
  // Statistics
  int _totalSessions = 0;
  int _successfulSessions = 0;
  double _averageReduction = 0.0;

  final List<int> _presetTimes = [300, 600, 900, 1200, 1800];

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadStatistics() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _totalSessions = prefs.getInt('urge_timer_total') ?? 0;
      _successfulSessions = prefs.getInt('urge_timer_successful') ?? 0;
      _averageReduction = prefs.getDouble('urge_timer_avg_reduction') ?? 0.0;
    });
  }

  Future<void> _saveSession(bool completed) async {
    final prefs = await SharedPreferences.getInstance();
    
    final total = _totalSessions + 1;
    final successful = completed ? _successfulSessions + 1 : _successfulSessions;
    
    double newAvgReduction = _averageReduction;
    if (completed && _finalIntensity != null && _initialIntensity != null) {
      final reduction = (_initialIntensity! - _finalIntensity!).toDouble();
      newAvgReduction = ((_averageReduction * _successfulSessions) + reduction) / successful;
    }
    
    await prefs.setInt('urge_timer_total', total);
    await prefs.setInt('urge_timer_successful', successful);
    await prefs.setDouble('urge_timer_avg_reduction', newAvgReduction);
    
    final history = prefs.getStringList('urge_timer_history') ?? [];
    final session = {
      'timestamp': DateTime.now().toIso8601String(),
      'duration': _totalSeconds ~/ 60,
      'completed': completed,
      'initial_intensity': _initialIntensity,
      'final_intensity': _finalIntensity,
    };
    history.add(json.encode(session));
    
    if (history.length > 50) {
      history.removeAt(0);
    }
    
    await prefs.setStringList('urge_timer_history', history);
    
    setState(() {
      _totalSessions = total;
      _successfulSessions = successful;
      _averageReduction = newAvgReduction;
    });
  }

  void _showInitialIntensityDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Rate Your Urge'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'How strong is your craving right now?',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 24),
            ...List.generate(10, (index) {
              final rating = index + 1;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _initialIntensity = rating;
                      });
                      Navigator.pop(context);
                      _startTimer();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: rating <= 3
                          ? const Color(0xFF10B981)
                          : rating <= 6
                              ? const Color(0xFFF59E0B)
                              : const Color(0xFFDC2626),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      '$rating - ${_getIntensityLabel(rating)}',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  void _showFinalIntensityDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('How Do You Feel Now?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Rate your craving intensity after waiting:',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 24),
            ...List.generate(10, (index) {
              final rating = index + 1;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      setState(() {
                        _finalIntensity = rating;
                      });
                      Navigator.pop(context);
                      await _saveSession(true);
                      
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              _initialIntensity! > rating
                                  ? 'Great job! Your craving decreased by ${_initialIntensity! - rating} points!'
                                  : 'You made it through! That takes strength.',
                            ),
                            backgroundColor: const Color(0xFF10B981),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: rating <= 3
                          ? const Color(0xFF10B981)
                          : rating <= 6
                              ? const Color(0xFFF59E0B)
                              : const Color(0xFFDC2626),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      '$rating - ${_getIntensityLabel(rating)}',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  String _getIntensityLabel(int rating) {
    if (rating <= 2) return 'Very Mild';
    if (rating <= 4) return 'Mild';
    if (rating <= 6) return 'Moderate';
    if (rating <= 8) return 'Strong';
    return 'Very Strong';
  }

  void _startTimer() {
    setState(() {
      _isRunning = true;
      _isComplete = false;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        _completeTimer();
      }
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
    });
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _isComplete = false;
      _remainingSeconds = _totalSeconds;
      _initialIntensity = null;
      _finalIntensity = null;
    });
  }

  void _completeTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _isComplete = true;
      _remainingSeconds = 0;
    });
    _showFinalIntensityDialog();
  }

  void _setTime(int seconds) {
    if (!_isRunning) {
      setState(() {
        _totalSeconds = seconds;
        _remainingSeconds = seconds;
        _isComplete = false;
      });
    }
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  double get _progress {
    if (_totalSeconds == 0) return 0;
    return (_totalSeconds - _remainingSeconds) / _totalSeconds;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFEF3F2),
      appBar: AppBar(
        backgroundColor: const Color(0xFFEA580C),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Urge Surfing Timer',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              color: const Color(0xFFEA580C),
              child: Column(
                children: [
                  const Icon(
                    Icons.waves,
                    color: Colors.white,
                    size: 48,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Ride the Wave',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Cravings peak and pass. You can outlast this urge.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  // Statistics card
                  if (_totalSessions > 0) ...[
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'Your Progress',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1F2937),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildStatItem(
                                'Total Sessions',
                                _totalSessions.toString(),
                                Icons.timer,
                              ),
                              _buildStatItem(
                                'Completed',
                                _successfulSessions.toString(),
                                Icons.check_circle,
                              ),
                              _buildStatItem(
                                'Avg Drop',
                                '${_averageReduction.toStringAsFixed(1)} pts',
                                Icons.trending_down,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Timer display
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Initial intensity display
                        if (_initialIntensity != null && !_isComplete) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF3F2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Starting intensity: $_initialIntensity/10',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFFEA580C),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],

                        // Circular progress
                        SizedBox(
                          width: 200,
                          height: 200,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                width: 200,
                                height: 200,
                                child: CircularProgressIndicator(
                                  value: _progress,
                                  strokeWidth: 12,
                                  backgroundColor: const Color(0xFFF3F4F6),
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    _isComplete
                                        ? const Color(0xFF10B981)
                                        : const Color(0xFFEA580C),
                                  ),
                                ),
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (_isComplete)
                                    const Icon(
                                      Icons.check_circle,
                                      size: 48,
                                      color: Color(0xFF10B981),
                                    )
                                  else
                                    Text(
                                      _formatTime(_remainingSeconds),
                                      style: TextStyle(
                                        fontSize: 48,
                                        fontWeight: FontWeight.bold,
                                        color: _isRunning
                                            ? const Color(0xFFEA580C)
                                            : const Color(0xFF6B7280),
                                      ),
                                    ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _isComplete
                                        ? 'You Did It!'
                                        : _isRunning
                                            ? 'Keep Going'
                                            : 'Ready',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Color(0xFF6B7280),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Results display
                        if (_isComplete &&
                            _initialIntensity != null &&
                            _finalIntensity != null) ...[
                          const SizedBox(height: 20),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFECFDF5),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '$_initialIntensity',
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFFDC2626),
                                      ),
                                    ),
                                    const Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 12),
                                      child: Icon(
                                        Icons.arrow_forward,
                                        color: Color(0xFF10B981),
                                      ),
                                    ),
                                    Text(
                                      '$_finalIntensity',
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF10B981),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _initialIntensity! > _finalIntensity!
                                      ? 'Craving dropped ${_initialIntensity! - _finalIntensity!} points!'
                                      : 'You made it through!',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.green[800],
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        const SizedBox(height: 32),

                        // Control buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (!_isComplete) ...[
                              if (_isRunning ||
                                  (_remainingSeconds != _totalSeconds &&
                                      _initialIntensity != null))
                                IconButton(
                                  onPressed: _resetTimer,
                                  icon: const Icon(Icons.refresh),
                                  iconSize: 32,
                                  color: const Color(0xFF6B7280),
                                ),
                              const SizedBox(width: 16),
                              ElevatedButton(
                                onPressed: () {
                                  if (_isRunning) {
                                    _pauseTimer();
                                  } else if (_initialIntensity == null) {
                                    _showInitialIntensityDialog();
                                  } else {
                                    _startTimer();
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _isRunning
                                      ? const Color(0xFF6B7280)
                                      : const Color(0xFFEA580C),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 40,
                                    vertical: 20,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      _isRunning ? Icons.pause : Icons.play_arrow,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      _isRunning ? 'Pause' : 'Start',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ] else ...[
                              ElevatedButton(
                                onPressed: _resetTimer,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF10B981),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 40,
                                    vertical: 20,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: const Text(
                                  'Start Again',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Time presets
                  if (!_isRunning && !_isComplete && _initialIntensity == null) ...[
                    const Text(
                      'Choose Duration',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children: _presetTimes.map((seconds) {
                        final isSelected = _totalSeconds == seconds;
                        final minutes = seconds ~/ 60;
                        return ChoiceChip(
                          label: Text('$minutes min'),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) {
                              _setTime(seconds);
                            }
                          },
                          selectedColor: const Color(0xFFEA580C),
                          backgroundColor: Colors.white,
                          labelStyle: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : const Color(0xFF6B7280),
                            fontWeight: FontWeight.w600,
                          ),
                          side: BorderSide(
                            color: isSelected
                                ? const Color(0xFFEA580C)
                                : const Color(0xFFE5E7EB),
                          ),
                        );
                      }).toList(),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Tips card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEF3F2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.lightbulb_outline,
                                color: Color(0xFFEA580C),
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'While You Wait',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1F2937),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildTip('Remind yourself: "This is temporary"'),
                        _buildTip('Notice the urge without judgment'),
                        _buildTip('Focus on your breathing'),
                        _buildTip('Call your support person'),
                        _buildTip('Move your body - walk, stretch, dance'),
                        _buildTip('Drink cold water'),
                      ],
                    ),
                  ),

                  if (_isComplete && _finalIntensity != null) ...[
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFECFDF5),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFD1FAE5)),
                      ),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.celebration,
                            color: Color(0xFF10B981),
                            size: 32,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'You Outlasted the Urge!',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.green[900],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'This is a huge victory. You proved you can handle cravings without using.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.green[800],
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFFEA580C), size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }

  Widget _buildTip(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Color(0xFFEA580C),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF374151),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}