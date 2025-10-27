import 'package:flutter/material.dart';
import 'p2p_sync.dart';

class SyncHostPage extends StatefulWidget {
  const SyncHostPage({super.key});
  @override
  State<SyncHostPage> createState() => _SyncHostPageState();
}

class _SyncHostPageState extends State<SyncHostPage> {
  final host = SyncHost();
  bool started = false;
  final log = StringBuffer();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('جلسة تزامن - المضيف')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(
              onPressed: started
                  ? null
                  : () async {
                      await host.start(port: 8080);
                      setState(() => started = true);
                      log.writeln('Server on 0.0.0.0:8080');
                    },
              child: const Text('بدء الاستقبال'),
            ),
            const SizedBox(height: 12),
            Expanded(child: SingleChildScrollView(child: Text(log.toString()))),
          ],
        ),
      ),
    );
  }
}

class SyncClientPage extends StatelessWidget {
  const SyncClientPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('جلسة تزامن - العميل')),
    body: const Center(
      child: Text('Scan QR / أدخل IP المضيف ثم Push/Pull (لاحقًا).'),
    ),
  );
}
