import 'package:flutter/material.dart';
import 'package:kasa_w_grupie/core/group.dart';

class CurrencySelector extends StatelessWidget {
  final CurrencyEnum selectedCurrency;
  final ValueChanged<CurrencyEnum> onCurrencySelected;
  final bool isSelectingFriends;
  final ValueChanged<bool> onExpansionChanged;

  const CurrencySelector({
    super.key,
    required this.selectedCurrency,
    required this.onCurrencySelected,
    required this.isSelectingFriends,
    required this.onExpansionChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ExpansionTile(
        title: Text(
          selectedCurrency.name.toUpperCase(),
          style: TextStyle(fontSize: 16),
        ),
        leading: Icon(Icons.attach_money),
        trailing: Icon(
          isSelectingFriends ? Icons.arrow_drop_up : Icons.arrow_drop_down,
        ),
        onExpansionChanged: onExpansionChanged,
        children: [
          Container(
            constraints: BoxConstraints(
              maxHeight: 200,
            ),
            child: ListView(
              shrinkWrap: true,
              children: CurrencyEnum.values.map((currency) {
                return ListTile(
                  title: Text(currency.name.toUpperCase()),
                  onTap: () {
                    onCurrencySelected(currency);
                    onExpansionChanged(false);
                  },
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
