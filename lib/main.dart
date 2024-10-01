import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

List<CameraDescription>? cameras;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  runApp(NeckPostureApp());
}

class NeckPostureApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Neck Posture Monitor',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: NeckPostureScreen(),
    );
  }
}

class NeckPostureScreen extends StatefulWidget {
  @override
  _NeckPostureScreenState createState() => _NeckPostureScreenState();
}

class _NeckPostureScreenState extends State<NeckPostureScreen> {
  CameraController? _controller;
  bool isTurtleNeck = false; // 거북목 여부를 위한 상태
  double neckAngle = 0.0; // 목의 각도를 위한 상태

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  void _initializeCamera() async {
    _controller = CameraController(cameras![0], ResolutionPreset.medium);
    await _controller?.initialize();
    if (!mounted) return;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Neck Posture Monitor'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: _controller != null && _controller!.value.isInitialized
                ? AspectRatio(
                    aspectRatio: _controller!.value.aspectRatio,
                    child: CameraPreview(_controller!),
                  )
                : Center(child: CircularProgressIndicator()),
          ),
          SizedBox(height: 20),
          Expanded(
            flex: 1,
            child: _buildFeedbackSection(),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackSection() {
    return Column(
      children: [
        Text(
          '실시간 피드백',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 20),
        Text(
          '목의 각도: ${neckAngle.toStringAsFixed(2)}°',
          style: TextStyle(fontSize: 18),
        ),
        SizedBox(height: 10),
        Text(
          isTurtleNeck ? '거북목 상태 감지됨!' : '정상 자세입니다.',
          style: TextStyle(
            fontSize: 18,
            color: isTurtleNeck ? Colors.red : Colors.green,
          ),
        ),
        SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            // 테스트를 위해 임의로 상태 변경
            setState(() {
              neckAngle = 30.0;
              isTurtleNeck = !isTurtleNeck;
            });
          },
          child: Text('테스트: 상태 변경'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}
