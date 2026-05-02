import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:flutter_callkit_incoming/entities/entities.dart';
import 'package:uuid/uuid.dart';

class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  final TextEditingController _nameController =
      TextEditingController(text: 'Mom');
  final TextEditingController _numberController =
      TextEditingController(text: '+62 812-3456-7890');
  double _delaySeconds = 15;
  bool _isCounting = false;
  int _countdown = 0;
  Timer? _timer;
  String? _currentCallId;

  @override
  void initState() {
    super.initState();
    _listenCallKit();
  }

  void _listenCallKit() {
    FlutterCallkitIncoming.onEvent.listen((CallEvent? event) {
      if (event == null) return;
      switch (event.event) {
        case Event.actionCallDecline:
        case Event.actionCallEnded:
          _endCall();
          break;
        default:
          break;
      }
    });
  }

  Future<void> _showNativeCall() async {
    _currentCallId = const Uuid().v4();

    final params = CallKitParams(
      id: _currentCallId,
      nameCaller: _nameController.text.isEmpty ? 'Unknown' : _nameController.text,
      appName: 'Phone',
      handle: _numberController.text.isEmpty ? 'mobile' : _numberController.text,
      type: 0,
      duration: 30000,
      textAccept: 'Accept',
      textDecline: 'Decline',
      missedCallNotification: const NotificationParams(
        showNotification: false,
        isShowCallback: false,
      ),
      android: const AndroidParams(
        isCustomNotification: true,
        isShowLogo: false,
        ringtonePath: 'system_ringtone_default',
        backgroundColor: '#0955fa',
        actionColor: '#4CAF50',
        textColor: '#ffffff',
        incomingCallNotificationChannelName: 'Incoming Call',
        missedCallNotificationChannelName: 'Missed Call',
        isShowCallID: false,
      ),
      ios: const IOSParams(
        iconName: 'CallKitLogo',
        handleType: 'number',
        supportsVideo: false,
        maximumCallGroups: 1,
        maximumCallsPerCallGroup: 1,
        audioSessionMode: 'default',
        audioSessionActive: true,
        audioSessionPreferredSampleRate: 44100.0,
        audioSessionPreferredIOBufferDuration: 0.005,
        supportsDTMF: true,
        supportsHolding: false,
        supportsGrouping: false,
        supportsUngrouping: false,
        ringtonePath: 'system_ringtone_default',
      ),
    );

    await FlutterCallkitIncoming.showCallkitIncoming(params);
  }

  void _startFakeCall() {
    if (_isCounting) return;
    HapticFeedback.mediumImpact();
    setState(() {
      _countdown = _delaySeconds.toInt();
      _isCounting = true;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() => _countdown--);
      if (_countdown <= 0) {
        timer.cancel();
        setState(() => _isCounting = false);
        _showNativeCall();
      }
    });
  }

  void _cancelCall() {
    _timer?.cancel();
    if (_currentCallId != null) {
      FlutterCallkitIncoming.endCall(_currentCallId!);
    }
    setState(() {
      _isCounting = false;
      _countdown = 0;
    });
  }

  void _endCall() {
    setState(() {
      _isCounting = false;
      _countdown = 0;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _nameController.dispose();
    _numberController.dispose();
    super.dispose();
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, bottom: 6, top: 22),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 13,
          color: Color(0xFF6C6C70),
          letterSpacing: 0.08,
        ),
      ),
    );
  }

  Widget _buildGroup(List<Widget> children) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildRow({required Widget leading, required Widget trailing, bool divider = true}) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [leading, trailing],
          ),
        ),
        if (divider)
          const Divider(height: 0, indent: 16, color: Color(0xFFE5E5EA)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: const Color(0xFFF2F2F7),
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: const Center(
                child: Text(
                  'Fake Call',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            const Divider(height: 0, color: Color(0xFFC8C7CC)),
            Expanded(
              child: ListView(
                children: [
                  _buildSectionHeader('Caller Info'),
                  _buildGroup([
                    _buildRow(
                      leading: const Text('Name',
                          style: TextStyle(fontSize: 16, color: Colors.black)),
                      trailing: SizedBox(
                        width: 160,
                        child: CupertinoTextField(
                          controller: _nameController,
                          textAlign: TextAlign.end,
                          placeholder: 'Mom',
                          decoration: null,
                          style: const TextStyle(fontSize: 16, color: Color(0xFF007AFF)),
                        ),
                      ),
                    ),
                    _buildRow(
                      leading: const Text('Number',
                          style: TextStyle(fontSize: 16, color: Colors.black)),
                      trailing: SizedBox(
                        width: 170,
                        child: CupertinoTextField(
                          controller: _numberController,
                          textAlign: TextAlign.end,
                          keyboardType: TextInputType.phone,
                          placeholder: '+62 812-xxx',
                          decoration: null,
                          style: const TextStyle(fontSize: 16, color: Color(0xFF007AFF)),
                        ),
                      ),
                      divider: false,
                    ),
                  ]),

                  _buildSectionHeader('Timing'),
                  _buildGroup([
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Call in',
                                  style: TextStyle(fontSize: 16, color: Colors.black)),
                              Text('${_delaySeconds.toInt()}s',
                                  style: const TextStyle(
                                      fontSize: 16,
                                      color: Color(0xFF007AFF),
                                      fontWeight: FontWeight.w600)),
                            ],
                          ),
                          SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              activeTrackColor: const Color(0xFF007AFF),
                              inactiveTrackColor: const Color(0xFFE5E5EA),
                              thumbColor: Colors.white,
                              overlayColor: Colors.transparent,
                              thumbShape: const RoundSliderThumbShape(
                                  enabledThumbRadius: 12, elevation: 3),
                              trackHeight: 4,
                            ),
                            child: Slider(
                              value: _delaySeconds,
                              min: 5,
                              max: 60,
                              divisions: 11,
                              onChanged: _isCounting
                                  ? null
                                  : (v) => setState(() => _delaySeconds = v),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              Text('5s', style: TextStyle(fontSize: 11, color: Color(0xFF8E8E93))),
                              Text('60s', style: TextStyle(fontSize: 11, color: Color(0xFF8E8E93))),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ]),

                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: GestureDetector(
                      onTap: _isCounting ? _cancelCall : _startFakeCall,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: _isCounting
                              ? const Color(0xFFFF3B30)
                              : const Color(0xFF34C759),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            _isCounting
                                ? 'Cancel  (${_countdown}s)'
                                : 'Schedule Fake Call',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Put your phone in your pocket. The real iOS call screen will appear automatically!',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: Color(0xFF8E8E93)),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
