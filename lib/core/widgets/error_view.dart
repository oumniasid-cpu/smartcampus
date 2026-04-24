import 'package:flutter/material.dart';
 
// --- LoadingView ---
class LoadingView extends StatelessWidget {
  const LoadingView({super.key});
 
  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}
 
// --- ErrorView ---
class ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
 
  const ErrorView({super.key, required this.message, this.onRetry});
 
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline,
                size: 56, color: Theme.of(context).colorScheme.error),
            const SizedBox(height: 16),
            Text(message,
                textAlign: TextAlign.center,
                style: TextStyle(color: Theme.of(context).colorScheme.error)),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Réessayer'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
 
// --- OfflineBanner ---
class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});
 
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.orange.shade700,
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      child: const Row(
        children: [
          Icon(Icons.wifi_off, color: Colors.white, size: 16),
          SizedBox(width: 8),
          Text('Mode hors ligne — données en cache',
              style: TextStyle(color: Colors.white, fontSize: 13)),
        ],
      ),
    );
  }
}