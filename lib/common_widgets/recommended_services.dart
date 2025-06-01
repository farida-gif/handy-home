import 'package:flutter/material.dart';

class RecommendedServices extends StatelessWidget {
  final Map iObj;
  const RecommendedServices({super.key, required this.iObj});

  @override
  Widget build(BuildContext context) {

    var media = MediaQuery.of(context).size;
    return SizedBox(
        width: media.width * 0.32,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: const [
                    BoxShadow(
                        color: Colors.black38,
                        offset: Offset(0, 2),
                        blurRadius: 5)
                  ]),
//img
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  iObj["img"].toString(),
                  width: media.width * 0.32,
                  height: media.width * 0.50,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(
              height: 15,
            ),
//name
            Text(
              iObj["name"].toString(),
              maxLines: 3,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 13,
                  fontWeight: FontWeight.w700),
            ),
            
          ],
        ));
  }
}