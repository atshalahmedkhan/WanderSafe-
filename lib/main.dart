import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:vibration/vibration.dart';

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
                  title: 'Distance Tracking',
                  description: 'Precise distance measurement to objects',
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

final String backendUrl = 'http://10.253.87.226:5000/detect';
final int processingIntervalMs = 1000;

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
    try {
      var request = http.MultipartRequest('POST', Uri.parse(backendUrl));
      request.files.add(await http.MultipartFile.fromPath('image', imagePath));
      var response = await request.send().timeout(Duration(seconds: 2));
      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        var jsonData = json.decode(responseData);
        debugPrint('Backend response: $responseData');
        List<DetectedObject> objects = (jsonData['objects'] as List)
            .map((obj) => DetectedObject.fromJson(obj))
            .toList();
        if (mounted) {
          setState(() {
            _detectedObjects = objects;
            _statusMessage = '${objects.length} objects detected';
          });
        }
        bool shouldVibrate = jsonData['should_vibrate'] == true;
        double closestDist = 999.0;
        for (var obj in objects) {
          if (obj.isHazard && obj.distance < 2.5) {
            shouldVibrate = true;
            if (obj.distance < closestDist) closestDist = obj.distance;
            debugPrint('Hazard: ${obj.label} at ${obj.distance}m');
          }
        }
        if (shouldVibrate && closestDist < 999.0) {
          debugPrint('TRIGGERING VIBRATION');
          await _triggerVibration(distance: closestDist);
        }
        _checkForHazards(objects);
      }
    } catch (e) {
      debugPrint('Backend error: $e');
    }
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
