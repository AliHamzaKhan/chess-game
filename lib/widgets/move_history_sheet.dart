import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/game_controller.dart';
import 'glass_container.dart';

class MoveHistorySheet extends StatelessWidget {
  final GameController controller = Get.find<GameController>();

  MoveHistorySheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Move History", style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
              IconButton(onPressed: () => Get.back(), icon: const Icon(Icons.close)),
            ],
          ),
          const Divider(),
          const SizedBox(height: 10),
          Expanded(
            child: Obx(() {
               final history = controller.history;
               if (history.isEmpty) {
                   return const Center(child: Text("No moves yet"));
               }
               
               return ListView.builder(
                 itemCount: (history.length / 2).ceil(),
                 itemBuilder: (context, index) {
                    final int moveNum = index + 1;
                    final int whiteIndex = index * 2;
                    final int blackIndex = whiteIndex + 1;
                    
                    final String whiteMove = history[whiteIndex];
                    final String blackMove = blackIndex < history.length ? history[blackIndex] : "";
                    
                    return Container(
                       margin: const EdgeInsets.only(bottom: 8),
                       padding: const EdgeInsets.all(12),
                       decoration: BoxDecoration(
                           color: index % 2 == 0 ? Colors.grey.withOpacity(0.05) : Colors.transparent,
                           borderRadius: BorderRadius.circular(8)
                       ),
                       child: Row(
                         children: [
                            SizedBox(
                                width: 40, 
                                child: Text("$moveNum.", style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold))
                            ),
                            Expanded(child: Text(whiteMove, style: const TextStyle(fontWeight: FontWeight.w500))),
                            Expanded(child: Text(blackMove, style: const TextStyle(fontWeight: FontWeight.w500))),
                         ],
                       ),
                    );
                 },
               );
            }),
          ),
        ],
      ),
    );
  }
}
