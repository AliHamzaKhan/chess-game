import 'package:flutter/material.dart';

class BackgroundScaffold extends StatelessWidget {
  final Widget? body;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;

  const BackgroundScaffold({
    super.key, 
    this.body, 
    this.appBar, 
    this.bottomNavigationBar,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: appBar,
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
      body: Stack(
        children: [
          // Gradient Background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark 
                  ? [const Color(0xFF0F172A), const Color(0xFF1E1B4B), const Color(0xFF312E81)] 
                  : [const Color(0xFFF3F4F6), const Color(0xFFE0E7FF), const Color(0xFFC7D2FE)],
              ),
            ),
          ),
          // Decorational Orbs/Glows
          Positioned(
             top: -100, right: -100,
             child: Container(
                width: 300, height: 300,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                    boxShadow: [
                         BoxShadow(blurRadius: 100, spreadRadius: 50, color: Theme.of(context).colorScheme.primary.withOpacity(0.2)),
                    ]
                ),
             )
          ),
           Positioned(
             bottom: -50, left: -50,
             child: Container(
                width: 250, height: 250,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).colorScheme.secondary.withOpacity(0.15),
                    boxShadow: [
                         BoxShadow(blurRadius: 100, spreadRadius: 50, color: Theme.of(context).colorScheme.secondary.withOpacity(0.15)),
                    ]
                ),
             )
          ),
          
          SafeArea(child: body ?? const SizedBox.shrink()),
        ],
      ),
    );
  }
}
