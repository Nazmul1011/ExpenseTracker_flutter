import 'package:flutter/material.dart';
import 'package:your_app_name/shared/widgets/app_bar/app_bar.dart';
import 'package:your_app_name/shared/widgets/scaffold/app_scaffold.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      extendBodyBehindAppBar: true,
      appBar: TheAppBar(
        forceMaterialTransparency: true,
        showBackArrow: true,
        leadingWidget: RichText(
          text: const TextSpan(text: 'Good Afternoon\n', children: [
            TextSpan(
                text: 'Nazmul Hasan',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                )
            ),
            TextSpan(
              text: "hello there "
            ),
          ]),
        ),
        actions: [
          Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
                color: Colors.white.withAlpha(100),
                borderRadius: BorderRadius.circular(30)),
            child: const Icon(Icons.notification_add),
          ),
        ],
      ),
      body: Stack(
        children: [
          const Positioned(
              top:500,
              bottom: 0,
              left: 0,
              right: 0,
              child: Center(child: Text("hello world",style:
                TextStyle(fontSize: 40),))),

          Positioned.fill(
              top: 0,
              bottom: 638,
              right: 0,
              left: 0,
              child: Image.asset("assets/images/all_back_banner.png"))
        ],
      ),
    );
  }
}

// class HomeScreen extends StatelessWidget {
//   const HomeScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey.shade100,
//       body: Stack(
//         children: [
//           Positioned(
//             top: 0,
//             right: 0,
//             left: 0,
//             bottom: 500,
//             child: Image.asset(
//               "assets/images/home_screen_banner.png",
//               fit: BoxFit.cover,
//             ),
//           ),

//           Positioned(
//             top: 100,
//             left: 20,
//             right: 20,
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       "Good afternoon",
//                       style: GoogleFonts.lateef(
//                         fontSize: 28,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.black87,
//                       ),
//                     ),
//                     Text(
//                       "Nazmul Hasan",
//                       style: GoogleFonts.laBelleAurore(
//                         fontSize: 20,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.grey.shade700,
//                       ),
//                     ),
//                   ],
//                 ),
//                 Container(
//                   height: 45,
//                   width: 45,
//                   decoration: BoxDecoration(
//                     color: Colors.white.withAlpha(190),
//                     borderRadius: BorderRadius.circular(12),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black.withAlpha(100),
//                         blurRadius: 4,
//                         offset: const Offset(0, 2),
//                       ),
//                     ],
//                   ),
//                   child: const Icon(
//                     Icons.notifications_none,
//                     color: Colors.black87,
//                     size: 26,
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           Positioned(
//             top: 180,
//             left: 40,
//             right: 40,
//             child: Container(
//               padding: const EdgeInsets.all(20),
//               height: 200,
//               decoration: BoxDecoration(
//                 gradient: const LinearGradient(
//                   colors: [Colors.black87, Color.fromARGB(255, 20, 20, 20)],
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                 ),
//                 borderRadius: BorderRadius.circular(25),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withAlpha(300),
//                     blurRadius: 8,
//                     offset: const Offset(0, 5),
//                   ),
//                 ],
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Header Row
//                   Row(
//                     children: [
//                       Text(
//                         "Total Balance",
//                         style: GoogleFonts.lateef(
//                           fontSize: 22,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.white,
//                         ),
//                       ),
//                       const Spacer(),
//                       const Icon(Icons.more_horiz, color: Colors.white),
//                     ],
//                   ),
//                   const SizedBox(height: 10),
//                   const Text(
//                     "\$2,548.00",
//                     style: TextStyle(
//                       fontSize: 36,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.white,
//                     ),
//                   ),
//                   const SizedBox(height: 20),
//                   const Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Row(
//                         children: [
//                           Icon(Icons.arrow_upward,
//                               color: Colors.white70, size: 20),
//                           SizedBox(width: 6),
//                           Text(
//                             "Income",
//                             style: TextStyle(color: Colors.white70),
//                           ),
//                         ],
//                       ),
//                       Row(
//                         children: [
//                           Icon(Icons.arrow_downward,
//                               color: Colors.white70, size: 20),
//                           SizedBox(width: 6),
//                           Text(
//                             "Expenses",
//                             style: TextStyle(color: Colors.white70),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ),

//           // 🔹 Transactions List
//           Positioned(
//             top: 430,
//             left: 20,
//             right: 20,
//             bottom: 100,
//             child: SingleChildScrollView(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Header
//                   const Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text(
//                         "Transactions History",
//                         style: TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.black87,
//                         ),
//                       ),
//                       Text(
//                         "See all",
//                         style: TextStyle(color: Colors.grey),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 15),

//                   // Each transaction item
//                   buildTransactionTile("Upwork", "Today", "+ \$850.00", true,
//                       "assets/images/home_view_hero.png"),
//                   buildTransactionTile("Transfer", "Yesterday", "- \$85.00",
//                       false, "assets/images/home_view_hero.png"),
//                   buildTransactionTile("Paypal", "Jan 30, 2022", "+ \$1,406.00",
//                       true, "assets/images/home_view_hero.png"),
//                   buildTransactionTile("YouTube", "Jan 16, 2022", "- \$11.99",
//                       false, "assets/images/home_view_hero.png"),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           Get.toNamed(AppRoutes.introScreen);
//         },
//         backgroundColor: Colors.black87,
//         child: const Icon(Icons.add, size: 30, color: Colors.white),
//       ),
//       floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
//       bottomNavigationBar: const BottomAppBar(
//         color: Colors.white,
//         shape: CircularNotchedRectangle(),
//         notchMargin: 6.0,
//         child: Padding(
//           padding: EdgeInsets.symmetric(horizontal: 25, vertical: 10),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Icon(Icons.home, color: Colors.black87),
//               Icon(Icons.bar_chart, color: Colors.grey),
//               SizedBox(width: 40), // space for FAB
//               Icon(Icons.wallet, color: Colors.grey),
//               Icon(Icons.person, color: Colors.grey),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget buildTransactionTile(
//       String name, String date, String amount, bool isIncome, String iconPath) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 10),
//       child: Row(
//         children: [
//           CircleAvatar(
//             radius: 22,
//             backgroundColor: Colors.white,
//             backgroundImage: AssetImage(iconPath),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(name,
//                     style: const TextStyle(
//                         fontWeight: FontWeight.bold, color: Colors.black87)),
//                 Text(date, style: const TextStyle(color: Colors.grey)),
//               ],
//             ),
//           ),
//           Text(
//             amount,
//             style: TextStyle(
//               color: isIncome ? Colors.green : Colors.red,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
