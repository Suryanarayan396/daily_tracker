import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/services/life_os_repository.dart';

class RepositoryObserver extends StatefulWidget {
  final Widget Function(BuildContext context, LifeOSRepository repo) builder;

  const RepositoryObserver({
    super.key,
    required this.builder,
  });

  @override
  State<RepositoryObserver> createState() => _RepositoryObserverState();
}

class _RepositoryObserverState extends State<RepositoryObserver> {
  late final StreamSubscription<void> _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = LifeOSRepository().onChange.listen((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, LifeOSRepository());
  }
}
