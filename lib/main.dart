import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io'; // MOVE THIS HERE (before line 6)
import 'package:http/http.dart' as http;
import 'package:vibration/vibration.dart';
import 'dart:math';
import 'object_tracker.dart';

late List<CameraDescription> cameras;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Foresight',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF6366F1),
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        colorScheme: ColorScheme.dark(
          primary: const Color(0xFF6366F1),
          secondary: const Color(0xFF8B5CF6),
          surface: const Color(0xFF1E293B),
          background: const Color(0xFF0F172A),
        ),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));
    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));
    _controller.forward();
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (c, a, sa) => const HomePage(),
          transitionsBuilder: (c, a, sa, child) =>
              FadeTransition(opacity: a, child: child),
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF6366F1),
              const Color(0xFF8B5CF6),
              const Color(0xFF0F172A),
            ],
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF6366F1).withOpacity(0.3),
                          blurRadius: 40,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.visibility,
                      size: 80,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    'FORESIGHT',
                    style: TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 4,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'See Beyond Sight',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white.withOpacity(0.8),
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _startDetection() {
    if (cameras.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('No camera available'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (c, a, sa) => CameraScreen(cameras: cameras),
        transitionsBuilder: (c, a, sa, child) {
          var tween = Tween(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).chain(CurveTween(curve: Curves.easeInOut));
          return SlideTransition(position: a.drive(tween), child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [const Color(0xFF0F172A), const Color(0xFF1E293B)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                const SizedBox(height: 60),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF6366F1).withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.visibility,
                    size: 60,
                    color: Color(0xFF6366F1),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'FORESIGHT',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 3,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'AI-Powered Hazard Detection',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.6),
                    letterSpacing: 1,
                  ),
                ),
                const Spacer(),
                _buildFeatureCard(
                  icon: Icons.camera_alt,
                  title: 'Real-Time Detection',
                  description: 'Instant object recognition and hazard alerts',
                ),
                const SizedBox(height: 16),
                _buildFeatureCard(
                  icon: Icons.volume_up,
                  title: 'Audio Guidance',
                  description: 'Voice alerts for detected obstacles',
                ),
                const SizedBox(height: 16),
                _buildFeatureCard(
                  icon: Icons.my_location,
                  title: 'Predictive Navigation',
                  description: 'Anticipate moving hazards before collision',
                ),
                const Spacer(),
                ScaleTransition(
                  scale: _pulseAnimation,
                  child: Container(
                    width: double.infinity,
                    height: 65,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF6366F1).withOpacity(0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: _startDetection,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.play_arrow, size: 28),
                          SizedBox(width: 12),
                          Text(
                            'Start Detection',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1).withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF6366F1), size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DetectedObject {
  final String label;
  final double confidence;
  final double distance;
  final Rect boundingBox;
  final bool isHazard;

  DetectedObject({
    required this.label,
    required this.confidence,
    required this.distance,
    required this.boundingBox,
    required this.isHazard,
  });

  factory DetectedObject.fromJson(Map<String, dynamic> json) {
    return DetectedObject(
      label: json['label'] ?? 'Unknown',
      confidence: (json['confidence'] ?? 0.0).toDouble(),
      distance: (json['distance'] ?? 0.0).toDouble(),
      boundingBox: Rect.fromLTWH(
        (json['box']['x'] ?? 0.0).toDouble(),
        (json['box']['y'] ?? 0.0).toDouble(),
        (json['box']['width'] ?? 0.0).toDouble(),
        (json['box']['height'] ?? 0.0).toDouble(),
      ),
      isHazard: json['is_hazard'] ?? false,
    );
  }
}

class CameraScreen extends StatefulWidget {
  final List<CameraDescription> cameras;
  const CameraScreen({Key? key, required this.cameras}) : super(key: key);
  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

final String backendUrl = 'http://10.84.153.246:5000/detect';

final int processingIntervalMs = 2500;

class _CameraScreenState extends State<CameraScreen>
    with TickerProviderStateMixin {
  CameraController? _controller;
  FlutterTts _tts = FlutterTts();
  List<DetectedObject> _detectedObjects = [];
  bool _isProcessing = false;
  Timer? _processingTimer;
  String _statusMessage = 'Initializing...';
  late AnimationController _scanController;
  bool _isSpeaking = false;
  DateTime _lastSpokenTime = DateTime.now();
  bool _hasVibrator = false;
  DateTime _lastVibrationTime = DateTime.now();
  Map<String, TrackedObject> trackedObjects = {};
  int nextObjectId = 0;

  Future<void> _checkVibration() async {
    _hasVibrator = await Vibration.hasVibrator() ?? false;
    debugPrint('Vibrator available: $_hasVibrator');
  }

  @override
  void initState() {
    super.initState();
    _scanController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();
    _initializeCamera();
    _initializeTTS();
    _checkVibration();
  }

  Future<void> _triggerVibration({double distance = 2.0}) async {
    if (!_hasVibrator) {
      debugPrint('No vibrator available');
      return;
    }
    final timeSinceLastVibration = DateTime.now()
        .difference(_lastVibrationTime)
        .inMilliseconds;
    if (timeSinceLastVibration < 800) {
      debugPrint('Vibration on cooldown');
      return;
    }
    _lastVibrationTime = DateTime.now();
    try {
      debugPrint('VIBRATING at distance: ${distance}m');
      if (distance < 0.5) {
        Vibration.vibrate(duration: 500);
        await Future.delayed(Duration(milliseconds: 100));
        Vibration.vibrate(duration: 500);
        await Future.delayed(Duration(milliseconds: 100));
        Vibration.vibrate(duration: 500);
        debugPrint('URGENT vibration');
      } else if (distance < 1.5) {
        Vibration.vibrate(duration: 300);
        await Future.delayed(Duration(milliseconds: 200));
        Vibration.vibrate(duration: 300);
        debugPrint('WARNING vibration');
      } else if (distance < 2.5) {
        Vibration.vibrate(duration: 150);
        debugPrint('CAUTION vibration');
      }
    } catch (e) {
      debugPrint('Vibration error: $e');
    }
  }

  Future<void> _initializeCamera() async {
    if (widget.cameras.isEmpty) {
      setState(() => _statusMessage = 'No camera found');
      _speak('No camera available');
      return;
    }
    _controller = CameraController(
      widget.cameras.first,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );
    try {
      await _controller!.initialize();
      if (mounted) {
        setState(() => _statusMessage = 'Ready');
        _speak('Foresight activated');
        _startProcessing();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _statusMessage = 'Camera error');
        _speak('Camera initialization failed');
      }
    }
  }

  Future<void> _initializeTTS() async {
    await _tts.setLanguage("en-US");
    await _tts.setSpeechRate(0.5);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);
  }

  void _startProcessing() {
    _processingTimer = Timer.periodic(
      Duration(milliseconds: processingIntervalMs),
      (timer) => _processFrame(),
    );
  }

  Future<void> _processFrame() async {
    if (_controller == null ||
        !_controller!.value.isInitialized ||
        _isProcessing)
      return;
    setState(() => _isProcessing = true);
    try {
      final image = await _controller!.takePicture();
      await _sendToBackend(image.path);
    } catch (e) {
      debugPrint('Frame processing error: $e');
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _sendToBackend(String imagePath) async {
    print('\n>>> SENDING TO BACKEND: $backendUrl');
    try {
      var request = http.MultipartRequest('POST', Uri.parse(backendUrl));
      print('>>> Creating multipart request...');

      request.files.add(await http.MultipartFile.fromPath('image', imagePath));
      print('>>> Image added to request');

      print('>>> Sending request...');
      var response = await request.send().timeout(Duration(seconds: 5));
      print('>>> Response received! Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        print('\n=== BACKEND RESPONSE ===');
        print(responseData);
        print('========================\n');

        var jsonData = json.decode(responseData);
        List<DetectedObject> objects = (jsonData['objects'] as List)
            .map((obj) => DetectedObject.fromJson(obj))
            .toList();

        if (mounted) {
          setState(() {
            _detectedObjects = objects;
            _statusMessage = '${objects.length} objects detected';
          });
        }

        for (var obj in objects) {
          _processDetection(obj);
        }

        bool shouldVibrate = jsonData['should_vibrate'] == true;
        double closestDist = 999.0;

        for (var obj in objects) {
          if (obj.isHazard && obj.distance < 2.5) {
            shouldVibrate = true;
            if (obj.distance < closestDist) closestDist = obj.distance;
            print('>>> HAZARD: ${obj.label} at ${obj.distance}m');
          }
        }

        if (shouldVibrate && closestDist < 999.0) {
          print('>>> TRIGGERING VIBRATION');
          await _triggerVibration(distance: closestDist);
        }

        _checkForHazards(objects);
      } else {
        print('>>> Backend error: Status ${response.statusCode}');
      }
    } catch (e) {
      print('>>> ERROR: $e');
      print('>>> Error type: ${e.runtimeType}');
    }
  }

  // // PREDICTIVE NAVIGATION - TRACKING AND PREDICTION
  // void _processDetection(DetectedObject detection) {
  //   // Get bounding box center (normalized 0-1)
  //   double centerX = detection.boundingBox.center.dx;
  //   double centerY = detection.boundingBox.center.dy;
  //
  //   // Try to match with existing tracked object
  //   String? matchedId = _findMatchingObject(centerX, centerY);
  //
  //   if (matchedId == null) {
  //     // New object
  //     matchedId = 'obj_${nextObjectId++}';
  //     trackedObjects[matchedId] = TrackedObject(
  //       id: matchedId,
  //       positions: [],
  //       lastSeen: DateTime.now(),
  //       label: detection.label,
  //       isHazard: detection.isHazard,
  //     );
  //   }
  //
  //   // Update object
  //   var obj = trackedObjects[matchedId]!;
  //   obj.positions.add(Position(centerX, centerY, DateTime.now()));
  //   obj.distances.add(detection.distance);
  //   obj.lastSeen = DateTime.now();
  //   obj.label = detection.label;
  //   obj.isHazard = detection.isHazard;
  //
  //   // Keep last 15 positions for better prediction
  //   if (obj.positions.length > 15) {
  //     obj.positions.removeAt(0);
  //     obj.distances.removeAt(0);
  //   }
  //
  //   // Predict future trajectory (2 seconds ahead)
  //   if (obj.positions.length >= 4 && detection.isHazard) {
  //     var velocity = obj.getSmoothedVelocity();
  //     var predicted = obj.predictPosition(2.0);
  //     var timeToCollision = _calculateTimeToCollision(obj);
  //
  //     // Calculate if predicted path intersects with user path
  //     bool willInterfere = _checkPredictedCollision(predicted, velocity);
  //
  //     // Enhanced warning system with time-to-collision
  //     if (willInterfere && timeToCollision > 0 && timeToCollision < 5.0) {
  //       _showAdvancedPredictiveWarning(
  //         detection.label,
  //         detection.distance,
  //         velocity,
  //         timeToCollision,
  //         obj,
  //       );
  //     } else if (detection.distance < 2.5 && velocity.distance > 0.03) {
  //       // Object is moving and close - still warn even if not directly intersecting
  //       _showMovementAlert(detection.label, detection.distance, velocity);
  //     }
  //   }
  // }
  // PREDICTIVE NAVIGATION - TRACKING AND PREDICTION
  void _processDetection(DetectedObject detection) {
    // Get bounding box center (normalized 0-1)
    double centerX = detection.boundingBox.center.dx;
    double centerY = detection.boundingBox.center.dy;

    // Try to match with existing tracked object
    String? matchedId = _findMatchingObject(centerX, centerY);

    if (matchedId == null) {
      // New object
      matchedId = 'obj_${nextObjectId++}';
      trackedObjects[matchedId] = TrackedObject(
        id: matchedId,
        positions: [],
        lastSeen: DateTime.now(),
        label: detection.label,
        isHazard: detection.isHazard,
      );
    }

    // Update object with timestamp tracking
    var obj = trackedObjects[matchedId]!;
    obj.positions.add(Position(centerX, centerY, DateTime.now()));
    obj.distances.add(detection.distance);
    obj.lastSeen = DateTime.now();
    obj.label = detection.label;
    obj.isHazard = detection.isHazard;

    // Keep last 15 positions for better prediction
    if (obj.positions.length > 15) {
      obj.positions.removeAt(0);
      obj.distances.removeAt(0);
    }

    // OPTIMIZED: Predict future trajectory (reduced threshold from 4 to 3 frames)
    if (obj.positions.length >= 3 && detection.isHazard) {
      var velocity = obj.getSmoothedVelocity();

      // Only predict if actually moving (>0.05 m/s)
      if (velocity.distance > 0.05) {
        var predicted = obj.predictPosition(2.0);
        var timeToCollision = _calculateTimeToCollision(obj);

        // Calculate if predicted path intersects with user path
        bool willInterfere = _checkPredictedCollision(predicted, velocity);

        // Enhanced warning system with time-to-collision
        if (willInterfere && timeToCollision > 0 && timeToCollision < 5.0) {
          _showAdvancedPredictiveWarning(
            detection.label,
            detection.distance,
            velocity,
            timeToCollision,
            obj,
          );
          return;
        } else if (detection.distance < 2.5 && velocity.distance > 0.03) {
          // Object is moving and close - still warn even if not directly intersecting
          _showMovementAlert(detection.label, detection.distance, velocity);
        }
      }
    }
  }

  // String? _findMatchingObject(double x, double y) {
  //   double bestMatch = double.infinity;
  //   String? bestId;
  //
  //   for (var entry in trackedObjects.entries) {
  //     var obj = entry.value;
  //     if (obj.positions.isEmpty) continue;
  //
  //     var lastPos = obj.positions.last;
  //     double dist = sqrt(pow(lastPos.x - x, 2) + pow(lastPos.y - y, 2));
  //
  //     // Time-based decay: older objects are less likely to match
  //     var timeDiff = DateTime.now().difference(obj.lastSeen).inMilliseconds;
  //     if (timeDiff > 1500) continue; // Too old
  //
  //     // Distance threshold with time decay
  //     double threshold = 0.15 + (timeDiff / 10000.0);
  //
  //     if (dist < threshold && dist < bestMatch) {
  //       bestMatch = dist;
  //       bestId = entry.key;
  //     }
  //   }
  //   return bestId;
  // }
  String? _findMatchingObject(double x, double y) {
    double bestMatch = double.infinity;
    String? bestId;

    for (var entry in trackedObjects.entries) {
      var obj = entry.value;
      if (obj.positions.isEmpty) continue;

      var lastPos = obj.positions.last;
      double dist = sqrt(pow(lastPos.x - x, 2) + pow(lastPos.y - y, 2));

      // Time-based decay: older objects are less likely to match
      var timeDiff = DateTime.now().difference(obj.lastSeen).inMilliseconds;
      if (timeDiff > 3000) continue;

      // Distance threshold with time decay
      double threshold = 0.15 + (timeDiff / 10000.0);

      if (dist < threshold && dist < bestMatch) {
        bestMatch = dist;
        bestId = entry.key;
      }
    }
    return bestId;
  }

  double _calculateTimeToCollision(TrackedObject obj) {
    if (obj.positions.length < 3 || obj.distances.length < 3) return -1;

    // Calculate closing rate (how fast distance is decreasing)
    var recentDistances = obj.distances.sublist(obj.distances.length - 3);
    var distanceChange = recentDistances.first - recentDistances.last;
    var timeSpan =
        obj.positions.last.timestamp
            .difference(obj.positions[obj.positions.length - 3].timestamp)
            .inMilliseconds /
        1000.0;

    if (timeSpan == 0) return -1;

    double closingRate = distanceChange / timeSpan; // meters per second

    if (closingRate <= 0) return -1; // Moving away or stationary

    double currentDistance = obj.distances.last;
    double timeToCollision = currentDistance / closingRate;

    return timeToCollision;
  }

  bool _checkPredictedCollision(Position predicted, Offset velocity) {
    double screenCenterX = 0.5;
    double screenCenterY = 0.5;

    // Check if object is moving toward center of screen (user's path)
    bool movingTowardCenter =
        (predicted.x - screenCenterX).abs() < 0.25 &&
        (predicted.y - screenCenterY).abs() < 0.35;

    // Must be moving with significant velocity
    bool isMoving = velocity.distance > 0.03;

    return movingTowardCenter && isMoving;
  }

  // void _showAdvancedPredictiveWarning(
  //   String label,
  //   double distance,
  //   Offset velocity,
  //   double timeToCollision,
  //   TrackedObject obj,
  // ) {
  //   String direction = _getDetailedDirection(velocity);
  //   String urgencyLevel = timeToCollision < 2.0 ? 'URGENT' : 'CAUTION';
  //
  //   if (mounted) {
  //     setState(() {
  //       _statusMessage =
  //           '$urgencyLevel: $label approaching from $direction - ${distance.toStringAsFixed(1)}m (${timeToCollision.toStringAsFixed(1)}s)';
  //     });
  //   }
  //
  //   // Directional vibration pattern
  //   _triggerDirectionalVibration(direction, timeToCollision);
  //
  //   // Time-sensitive speech
  //   String speechText;
  //   if (timeToCollision < 1.5) {
  //     speechText = 'Stop! $label approaching fast from $direction!';
  //   } else if (timeToCollision < 3.0) {
  //     speechText =
  //         'Warning! $label moving toward you from $direction, ${timeToCollision.toStringAsFixed(0)} seconds away';
  //   } else {
  //     speechText = 'Caution: $label approaching from $direction';
  //   }
  //
  //   _speak(speechText);
  //
  //   debugPrint(
  //     'PREDICTIVE WARNING: $label moving $direction at ${distance}m, TTC: ${timeToCollision}s',
  //   );
  // }
  void _showAdvancedPredictiveWarning(
    String label,
    double distance,
    Offset velocity,
    double timeToCollision,
    TrackedObject obj,
  ) {
    String direction = _getDetailedDirection(velocity);
    String speedDesc = velocity.distance > 0.3 ? "quickly" : "slowly";
    String urgencyLevel = timeToCollision < 2.0 ? 'URGENT' : 'CAUTION';

    if (mounted) {
      setState(() {
        _statusMessage =
            '$urgencyLevel: $label $speedDesc moving from $direction - '
            '${distance.toStringAsFixed(1)}m (${timeToCollision.toStringAsFixed(1)}s)';
      });
    }

    _triggerDirectionalVibration(direction, timeToCollision);

    String speechText;
    if (timeToCollision < 1.5) {
      speechText = 'Stop! $label approaching fast from $direction!';
    } else if (timeToCollision < 3.0) {
      speechText =
          'Warning! $label moving toward you from $direction, '
          '${timeToCollision.toStringAsFixed(0)} seconds away';
    } else {
      speechText = 'Caution: $label approaching from $direction';
    }

    _speak(speechText);

    debugPrint(
      'PREDICTION: $label | Speed: ${(velocity.distance * 3.6).toStringAsFixed(1)} km/h | '
      'Distance: ${distance}m | TTC: ${timeToCollision}s',
    );
  }

  void _showMovementAlert(String label, double distance, Offset velocity) {
    String direction = _getDetailedDirection(velocity);

    if (DateTime.now().difference(_lastSpokenTime).inSeconds > 4) {
      _speak(
        '$label moving $direction at ${distance.toStringAsFixed(1)} meters',
      );
    }
  }

  Future<void> _triggerDirectionalVibration(
    String direction,
    double timeToCollision,
  ) async {
    if (!_hasVibrator) return;

    final timeSinceLastVibration = DateTime.now()
        .difference(_lastVibrationTime)
        .inMilliseconds;
    if (timeSinceLastVibration < 600) return;

    _lastVibrationTime = DateTime.now();

    try {
      if (timeToCollision < 1.5) {
        // URGENT: Rapid pulses
        for (int i = 0; i < 4; i++) {
          Vibration.vibrate(duration: 150);
          await Future.delayed(Duration(milliseconds: 100));
        }
      } else if (timeToCollision < 3.0) {
        // WARNING: Double pulse with direction encoding
        if (direction.contains('left') || direction.contains('right')) {
          Vibration.vibrate(duration: 200);
          await Future.delayed(Duration(milliseconds: 150));
          Vibration.vibrate(duration: 200);
        } else {
          Vibration.vibrate(duration: 300);
          await Future.delayed(Duration(milliseconds: 200));
          Vibration.vibrate(duration: 150);
        }
      } else {
        // CAUTION: Single pulse
        Vibration.vibrate(duration: 200);
      }
    } catch (e) {
      debugPrint('Vibration error: $e');
    }
  }

  String _getDirection(Offset velocity) {
    if (velocity.distance < 0.01) return 'stationary';

    double angle = atan2(velocity.dy, velocity.dx) * 180 / pi;

    if (angle > -45 && angle <= 45) return 'right';
    if (angle > 45 && angle <= 135) return 'down';
    if (angle > 135 || angle <= -135) return 'left';
    return 'up';
  }

  String _getDetailedDirection(Offset velocity) {
    if (velocity.distance < 0.02) return 'stationary';

    double angle = atan2(velocity.dy, velocity.dx) * 180 / pi;

    // More granular directions
    if (angle > -22.5 && angle <= 22.5) return 'your right';
    if (angle > 22.5 && angle <= 67.5) return 'lower right';
    if (angle > 67.5 && angle <= 112.5) return 'below';
    if (angle > 112.5 && angle <= 157.5) return 'lower left';
    if (angle > 157.5 || angle <= -157.5) return 'your left';
    if (angle > -157.5 && angle <= -112.5) return 'upper left';
    if (angle > -112.5 && angle <= -67.5) return 'above';
    return 'upper right';
  }

  void _checkForHazards(List<DetectedObject> objects) {
    if (objects.isEmpty) return;
    DetectedObject? closestHazard;
    double closestDistance = double.infinity;
    for (var obj in objects) {
      if (obj.isHazard && obj.distance < closestDistance) {
        closestDistance = obj.distance;
        closestHazard = obj;
      }
    }
    if (closestHazard != null) {
      String warning = closestHazard.distance < 1.0
          ? 'Stop! ${closestHazard.label} very close'
          : '${closestHazard.label} ahead at ${closestHazard.distance.toStringAsFixed(1)} meters';
      _speak(warning);
    }
  }

  Future<void> _speak(String text) async {
    if (_isSpeaking || DateTime.now().difference(_lastSpokenTime).inSeconds < 3)
      return;
    _isSpeaking = true;
    _lastSpokenTime = DateTime.now();
    debugPrint('Speaking: $text');
    await _tts.speak(text);
    await Future.delayed(Duration(seconds: 2));
    _isSpeaking = false;
  }

  @override
  void dispose() {
    _processingTimer?.cancel();
    _controller?.dispose();
    _tts.stop();
    _scanController.dispose();
    _isSpeaking = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                  ),
                ),
                child: const Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 3,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Text(
                _statusMessage,
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          CameraPreview(_controller!),
          AnimatedBuilder(
            animation: _scanController,
            builder: (c, ch) =>
                CustomPaint(painter: ScanLinePainter(_scanController.value)),
          ),
          CustomPaint(painter: FocusBoxPainter()),
          CustomPaint(painter: TrajectoryPainter(trackedObjects)),
          CustomPaint(painter: ObjectBoxPainter(_detectedObjects)),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.only(
                top: 50,
                left: 20,
                right: 20,
                bottom: 20,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black.withOpacity(0.7), Colors.transparent],
                ),
              ),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 24,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: const Color(0xFF6366F1).withOpacity(0.5),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.green.withOpacity(0.5),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _statusMessage,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            right: 20,
            bottom: 150,
            child: FloatingActionButton(
              backgroundColor: Colors.purple,
              onPressed: () {
                debugPrint('TEST: Vibrating now');
                Vibration.vibrate(duration: 500);
              },
              child: Icon(Icons.vibration),
            ),
          ),
          if (_detectedObjects.isNotEmpty)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Colors.black.withOpacity(0.9), Colors.transparent],
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'DETECTED OBJECTS',
                      style: TextStyle(
                        color: Color(0xFF6366F1),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ..._detectedObjects
                        .take(3)
                        .map(
                          (obj) => Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: obj.isHazard
                                  ? Colors.red.withOpacity(0.2)
                                  : Colors.green.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: obj.isHazard
                                    ? Colors.red.withOpacity(0.5)
                                    : Colors.green.withOpacity(0.5),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: obj.isHazard
                                        ? Colors.red
                                        : Colors.green,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    obj.isHazard
                                        ? Icons.warning
                                        : Icons.check_circle,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        obj.label.toUpperCase(),
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: obj.isHazard
                                              ? Colors.red
                                              : Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${obj.distance.toStringAsFixed(1)}m away',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.white.withOpacity(0.7),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (obj.isHazard)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Text(
                                      'HAZARD',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
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

class ScanLinePainter extends CustomPainter {
  final double progress;
  ScanLinePainter(this.progress);
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF6366F1).withOpacity(0.5)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(0, size.height * progress),
      Offset(size.width, size.height * progress),
      paint,
    );
  }

  @override
  bool shouldRepaint(ScanLinePainter oldDelegate) => true;
}

class FocusBoxPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width * 0.7;
    final h = size.height * 0.4;
    final l = (size.width - w) / 2;
    final t = (size.height - h) / 2;
    final len = 40.0;
    final p = Paint()
      ..color = const Color(0xFF6366F1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(l, t), Offset(l + len, t), p);
    canvas.drawLine(Offset(l, t), Offset(l, t + len), p);
    canvas.drawLine(Offset(l + w, t), Offset(l + w - len, t), p);
    canvas.drawLine(Offset(l + w, t), Offset(l + w, t + len), p);
    canvas.drawLine(Offset(l, t + h), Offset(l + len, t + h), p);
    canvas.drawLine(Offset(l, t + h), Offset(l, t + h - len), p);
    canvas.drawLine(Offset(l + w, t + h), Offset(l + w - len, t + h), p);
    canvas.drawLine(Offset(l + w, t + h), Offset(l + w, t + h - len), p);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class ObjectBoxPainter extends CustomPainter {
  final List<DetectedObject> objects;
  ObjectBoxPainter(this.objects);
  @override
  void paint(Canvas canvas, Size size) {
    for (var obj in objects) {
      final paint = Paint()
        ..color = obj.isHazard ? Colors.red : Colors.green
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0;
      final rect = Rect.fromLTWH(
        obj.boundingBox.left * size.width,
        obj.boundingBox.top * size.height,
        obj.boundingBox.width * size.width,
        obj.boundingBox.height * size.height,
      );
      canvas.drawRect(rect, paint);
      final textPainter = TextPainter(
        text: TextSpan(
          text: '${obj.label} ${obj.distance.toStringAsFixed(1)}m',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      final labelRect = Rect.fromLTWH(
        rect.left,
        rect.top - 30,
        textPainter.width + 16,
        24,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(labelRect, const Radius.circular(6)),
        Paint()..color = obj.isHazard ? Colors.red : Colors.green,
      );
      textPainter.paint(canvas, Offset(rect.left + 8, rect.top - 28));
    }
  }

  @override
  bool shouldRepaint(covariant ObjectBoxPainter oldDelegate) => true;
}

class TrajectoryPainter extends CustomPainter {
  final Map<String, TrackedObject> trackedObjects;
  TrajectoryPainter(this.trackedObjects);

  @override
  void paint(Canvas canvas, Size size) {
    for (var obj in trackedObjects.values) {
      if (obj.positions.length < 3) continue;
      if (!obj.isHazard) continue;

      // Only show trajectory for moving hazards
      var velocity = obj.getSmoothedVelocity();
      if (velocity.distance < 0.03) continue;

      // Draw trajectory line
      var current = obj.positions.last;
      var predicted = obj.predictPosition(2.0);

      final trajectoryPaint = Paint()
        ..color = Colors.orange.withOpacity(0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0
        ..strokeCap = StrokeCap.round;

      final dashPaint = Paint()
        ..color = Colors.red.withOpacity(0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;

      // Current position
      Offset start = Offset(current.x * size.width, current.y * size.height);

      // Predicted position
      Offset end = Offset(predicted.x * size.width, predicted.y * size.height);

      // Draw arrow from current to predicted
      _drawDashedLine(canvas, start, end, dashPaint, 10, 5);

      // Draw arrowhead at predicted position
      _drawArrowHead(canvas, start, end, Colors.red.withOpacity(0.8));

      // Draw prediction circle
      canvas.drawCircle(
        end,
        12,
        Paint()
          ..color = Colors.red.withOpacity(0.3)
          ..style = PaintingStyle.fill,
      );

      canvas.drawCircle(
        end,
        12,
        Paint()
          ..color = Colors.red
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0,
      );

      // Movement confidence indicator
      double confidence = obj.getMovementConfidence();
      if (confidence > 0.5) {
        final textPainter = TextPainter(
          text: TextSpan(
            text: '${(confidence * 100).toInt()}%',
            style: TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();

        textPainter.paint(
          canvas,
          Offset(end.dx - textPainter.width / 2, end.dy + 15),
        );
      }
    }
  }

  void _drawDashedLine(
    Canvas canvas,
    Offset start,
    Offset end,
    Paint paint,
    double dashWidth,
    double dashSpace,
  ) {
    double distance = (end - start).distance;
    double dashCount = distance / (dashWidth + dashSpace);

    for (int i = 0; i < dashCount.floor(); i++) {
      double t1 = i * (dashWidth + dashSpace) / distance;
      double t2 = (i * (dashWidth + dashSpace) + dashWidth) / distance;

      if (t2 > 1.0) t2 = 1.0;

      Offset dashStart = Offset(
        start.dx + (end.dx - start.dx) * t1,
        start.dy + (end.dy - start.dy) * t1,
      );

      Offset dashEnd = Offset(
        start.dx + (end.dx - start.dx) * t2,
        start.dy + (end.dy - start.dy) * t2,
      );

      canvas.drawLine(dashStart, dashEnd, paint);
    }
  }

  void _drawArrowHead(Canvas canvas, Offset start, Offset end, Color color) {
    const double arrowSize = 12;

    // Calculate angle
    double angle = atan2(end.dy - start.dy, end.dx - start.dx);

    // Calculate arrowhead points
    Offset arrowPoint1 = Offset(
      end.dx - arrowSize * cos(angle - pi / 6),
      end.dy - arrowSize * sin(angle - pi / 6),
    );

    Offset arrowPoint2 = Offset(
      end.dx - arrowSize * cos(angle + pi / 6),
      end.dy - arrowSize * sin(angle + pi / 6),
    );

    final arrowPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    Path arrowPath = Path()
      ..moveTo(end.dx, end.dy)
      ..lineTo(arrowPoint1.dx, arrowPoint1.dy)
      ..lineTo(arrowPoint2.dx, arrowPoint2.dy)
      ..close();

    canvas.drawPath(arrowPath, arrowPaint);
  }

  @override
  bool shouldRepaint(covariant TrajectoryPainter oldDelegate) => true;
}
