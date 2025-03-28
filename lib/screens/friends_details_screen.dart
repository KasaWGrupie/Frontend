import 'package:flutter/material.dart';

class FriendDetailsScreen extends StatelessWidget {
  final String friendName;
  final String friendEmail;
  final double owesAmount;
  final double owedAmount;

  const FriendDetailsScreen({
    super.key,
    required this.friendName,
    required this.friendEmail,
    required this.owesAmount,
    required this.owedAmount,
  });

  // Helper function to get balance info
  String getBalanceInfo() {
    if (owesAmount > 0) {
      return "Owes you: \$${owesAmount.toStringAsFixed(2)}";
    } else if (owedAmount > 0) {
      return "You owe: \$${owedAmount.toStringAsFixed(2)}";
    } else {
      return "No debts";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('$friendName - Balance Details')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Header Tile (User Info)
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  radius: 30,
                  child: Icon(Icons.person, size: 30, color: Colors.white),
                ),
                title: Text(
                  friendName,
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  friendEmail,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(color: Colors.grey),
                ),
              ),
            ),

            SizedBox(height: 20),

            // ListView for balances (structured for future extensions)
            Expanded(
              child: ListView(
                children: [
                  // Single Tile for Total Balance (for now)
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      title: Text(
                        "Total Balance",
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      subtitle: Text(
                        getBalanceInfo(),
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      trailing: ElevatedButton(
                        onPressed: () {
                          // Action logic (to be added later)
                        },
                        child: Text("Settle Up"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: owesAmount > 0
                              ? Colors.green
                              : owedAmount > 0
                                  ? Colors.red
                                  : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// import 'package:flutter/material.dart';

// class FriendDetailsScreen extends StatelessWidget {
//   final String friendName;
//   final String friendEmail;
//   final List<Map<String, dynamic>> groupBalances;

//   const FriendDetailsScreen({
//     super.key,
//     required this.friendName,
//     required this.friendEmail,
//     required this.groupBalances,
//   });

//   // Calculate total balance
//   double getTotalBalance() {
//     return groupBalances.fold(
//       0.0,
//       (sum, group) => sum + (group['owesAmount'] - group['owedAmount']),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     double totalBalance = getTotalBalance();

//     return Scaffold(
//       appBar: AppBar(title: Text('$friendName - Balance Details')),
//       body: Column(
//         children: [
//           // Header Tile (User Info)
//           Card(
//             elevation: 4,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(12),
//             ),
//             margin: const EdgeInsets.all(16),
//             child: ListTile(
//               leading: CircleAvatar(
//                 radius: 30,
//                 child: Icon(Icons.person, size: 30, color: Colors.white),
//               ),
//               title: Text(
//                 friendName,
//                 style: Theme.of(context)
//                     .textTheme
//                     .titleLarge
//                     ?.copyWith(fontWeight: FontWeight.bold),
//               ),
//               subtitle: Text(
//                 friendEmail,
//                 style: Theme.of(context)
//                     .textTheme
//                     .titleMedium
//                     ?.copyWith(color: Colors.grey),
//               ),
//             ),
//           ),

//           // Group Balances List
//           Expanded(
//             child: ListView.builder(
//               itemCount: groupBalances.length,
//               itemBuilder: (context, index) {
//                 final group = groupBalances[index];
//                 final String groupName = group["groupName"];
//                 final double owesAmount = group["owesAmount"];
//                 final double owedAmount = group["owedAmount"];

//                 String balanceText;
//                 if (owesAmount > 0) {
//                   balanceText = "Owes you: \$${owesAmount.toStringAsFixed(2)}";
//                 } else if (owedAmount > 0) {
//                   balanceText = "You owe: \$${owedAmount.toStringAsFixed(2)}";
//                 } else {
//                   balanceText = "No debts";
//                 }

//                 return Card(
//                   elevation: 4,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   margin:
//                       const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                   child: ListTile(
//                     title: Text(
//                       groupName,
//                       style: Theme.of(context).textTheme.titleMedium,
//                     ),
//                     subtitle: Text(
//                       balanceText,
//                       style: Theme.of(context)
//                           .textTheme
//                           .headlineSmall
//                           ?.copyWith(fontWeight: FontWeight.bold),
//                     ),
//                     trailing: Icon(Icons.arrow_forward_ios),
//                     onTap: () {
//                       // Navigate to group details (Future Feature)
//                     },
//                   ),
//                 );
//               },
//             ),
//           ),

//           // Bottom Section (Total Sum & Settle Button)
//           Container(
//             padding: const EdgeInsets.all(16),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               border: Border(
//                 top: BorderSide(color: Colors.grey.shade300),
//               ),
//             ),
//             child: Column(
//               children: [
//                 // Total Balance Display
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       "Total Balance:",
//                       style: Theme.of(context)
//                           .textTheme
//                           .titleLarge
//                           ?.copyWith(fontWeight: FontWeight.bold),
//                     ),
//                     Text(
//                       "\$${totalBalance.toStringAsFixed(2)}",
//                       style:
//                           Theme.of(context).textTheme.headlineSmall?.copyWith(
//                               fontWeight: FontWeight.bold,
//                               color: totalBalance > 0
//                                   ? Colors.green
//                                   : totalBalance < 0
//                                       ? Colors.red
//                                       : Colors.black),
//                     ),
//                   ],
//                 ),

//                 const SizedBox(height: 12),

//                 // Settle Between Groups Button
//                 SizedBox(
//                   width: double.infinity,
//                   child: ElevatedButton(
//                     onPressed: () {
//                       // Handle settlement logic (Future Feature)
//                     },
//                     style: ElevatedButton.styleFrom(
//                       padding: const EdgeInsets.symmetric(vertical: 12),
//                       backgroundColor:
//                           totalBalance != 0 ? Colors.blueAccent : Colors.grey,
//                     ),
//                     child: Text(
//                       "Settle Between Groups",
//                       style: TextStyle(fontSize: 16, color: Colors.white),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
