import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class ShowWallpaperScreen extends StatefulWidget {
  final String wallpaper;
  const ShowWallpaperScreen({super.key, required this.wallpaper});

  @override
  State<ShowWallpaperScreen> createState() => _ShowWallpaperScreenState();
}

class _ShowWallpaperScreenState extends State<ShowWallpaperScreen> {
  bool _isDownloading = false;
  String _status = '';
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings("@mipmap/ic_launcher");

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await _notificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _requestPermissionAndDownload() async {
    setState(() {
      _isDownloading = true;
      _status = "Requesting permission...";
    });

    PermissionStatus status;
    if (Platform.isAndroid && (await _isAndroid11OrAbove())) {
      status = await Permission.manageExternalStorage.request();
    } else {
      status = await Permission.storage.request();
    }

    if (status.isGranted) {
      setState(() {
        _status = "Permission granted. Downloading...";
      });
      await _downloadImage();
    } else {
      setState(() {
        _status = "Permission denied";
        _isDownloading = false;
      });
    }
  }

  Future<void> _downloadImage() async {
    const String channelId = "download_channel_id";
    const String channelName = "Wallpaper Downloads";
    const int notificationId = 100;

    final androidPlatformChannelSpecifics = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: "Shows download progress of wallpapers",
      importance: Importance.low,
      priority: Priority.low,
      showProgress: true,
      maxProgress: 100,
      onlyAlertOnce: true,
    );

    final notificationDetails =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    try {
      await _notificationsPlugin.show(
        notificationId,
        "Downloading wallpaper...",
        "0%",
        notificationDetails,
      );

      final response = await http.Client()
          .send(http.Request("GET", Uri.parse(widget.wallpaper)));
      final contentLength = response.contentLength ?? 0;

      if (response.statusCode == 200) {
        final directory = Directory("/storage/emulated/0/marnihub");

        if (!await directory.exists()) {
          await directory.create(recursive: true);
        }

        final filePath =
            "${directory.path}/wallpaper_${DateTime.now().millisecondsSinceEpoch}.jpg";
        final file = File(filePath);
        final sink = file.openWrite();

        int bytesReceived = 0;
        await for (var chunk in response.stream) {
          bytesReceived += chunk.length;
          sink.add(chunk);

          int progress = (bytesReceived / contentLength * 100).floor();
          await _notificationsPlugin.show(
            notificationId,
            "Downloading wallpaper...",
            "$progress%",
            NotificationDetails(
              android: AndroidNotificationDetails(
                channelId,
                channelName,
                channelDescription: "Shows download progress of wallpapers",
                importance: Importance.high,
                priority: Priority.high,
                showProgress: true,
                maxProgress: 100,
                progress: progress,
                onlyAlertOnce: true,
              ),
            ),
          );
        }

        await sink.close();

        setState(() {
          _status = "Downloaded to: ${directory.path}";
        });

        // Show completion notification
        await _notificationsPlugin.show(
          notificationId,
          "Download complete",
          "Wallpaper saved to ${directory.path}",
          NotificationDetails(
            android: AndroidNotificationDetails(
              channelId,
              channelName,
              channelDescription: "Download completed",
              importance: Importance.high,
              priority: Priority.high,
            ),
          ),
        );
      } else {
        setState(() {
          _status = "Failed to download image";
        });
      }
    } catch (e) {
      setState(() {
        _status = "Error: $e";
      });
    } finally {
      setState(() {
        _isDownloading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_status)),
        );
      }
    }
  }

  Future<bool> _isAndroid11OrAbove() async {
    final deviceInfo = DeviceInfoPlugin();
    final androidInfo = await deviceInfo.androidInfo;
    return androidInfo.version.sdkInt >= 30; // Android 11 = SDK 30
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(widget.wallpaper),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Center(
                child: InkWell(
                  onTap: _isDownloading ? null : _requestPermissionAndDownload,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 18.0),
                    width: MediaQuery.of(context).size.width / 1.25,
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: .8),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Center(
                      child: _isDownloading
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text(
                              "Download Wallpaper",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20.0,
                              ),
                            ),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 10.0,
              ),
              Center(
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 18.0),
                    width: MediaQuery.of(context).size.width / 1.25,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: .8),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Center(
                      child: Text(
                        "Back",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20.0,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 10.0,
              ),
            ],
          )
        ],
      ),
    );
  }
}
