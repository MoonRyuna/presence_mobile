import 'package:flutter/material.dart';
import 'package:presence_alpha/screen/splash_screen.dart';

class OfflineScreen extends StatefulWidget {
  const OfflineScreen({super.key});

  @override
  State<OfflineScreen> createState() => _OfflineScreenState();
}

class _OfflineScreenState extends State<OfflineScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.signal_wifi_off, size: 100),
              const SizedBox(height: 16),
              const Text(
                "Anda sedang offline",
                style: TextStyle(fontSize: 24),
              ),
              const SizedBox(height: 8),
              const Text(
                "Tolong cek koneksi internet Anda",
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[900],
                ),
                onPressed: () {
                  Navigator.of(context)
                      .pushReplacement(MaterialPageRoute(builder: (_) {
                    return const SplashScreen();
                  }));
                },
                child: const Text("Coba lagi"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
