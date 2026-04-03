import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/customer_type.dart';
import '../models/product.dart';
import '../providers/app_providers.dart';

class OrderScreen extends ConsumerWidget {
  const OrderScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productsProvider);
    final customerType = ref.watch(customerTypeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('B2B orders'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Customer type',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                SegmentedButton<CustomerType>(
                  segments: CustomerType.values
                      .map(
                        (t) => ButtonSegment<CustomerType>(
                          value: t,
                          label: Text(t.label),
                        ),
                      )
                      .toList(),
                  selected: {customerType},
                  onSelectionChanged: (s) {
                    ref.read(customerTypeProvider.notifier).state = s.first;
                  },
                ),
                const SizedBox(height: 4),
                Text(
                  'Dealer uses lower unit price; Retail uses higher unit price.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: productsAsync.when(
              data: (products) {
                if (products.isEmpty) {
                  return const Center(child: Text('No products'));
                }
                return ListView.separated(
                  padding: const EdgeInsets.only(bottom: 24),
                  itemCount: products.length,
                  separatorBuilder: (_, _) =>
                      const Divider(height: 1),
                  itemBuilder: (context, i) {
                    final p = products[i];
                    final unit = p.unitPrice(customerType);
                    return ListTile(
                      title: Text(p.name),
                      subtitle: Text(
                        'MOQ: ${p.moq}  ·  Unit: \$${unit.toStringAsFixed(2)} (${customerType.label})',
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _openOrderSheet(
                        context,
                        ref,
                        product: p,
                        customerType: customerType,
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text('Could not load products.\n$e'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openOrderSheet(
    BuildContext context,
    WidgetRef ref, {
    required Product product,
    required CustomerType customerType,
  }) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) {
        return _OrderSheet(
          product: product,
          customerType: customerType,
        );
      },
    );
  }
}

class _OrderSheet extends StatefulWidget {
  const _OrderSheet({
    required this.product,
    required this.customerType,
  });

  final Product product;
  final CustomerType customerType;

  @override
  State<_OrderSheet> createState() => _OrderSheetState();
}

class _OrderSheetState extends State<_OrderSheet> {
  final _controller = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    final t = widget.customerType;
    final qty = int.tryParse(_controller.text.trim());
    final total = (qty != null && qty >= p.moq) ? p.totalFor(t, qty) : null;

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 8,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            p.name,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text('MOQ: ${p.moq} (cannot order below)'),
          Text(
            'Unit price (${t.label}): \$${p.unitPrice(t).toStringAsFixed(2)}',
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Quantity',
              errorText: _error,
              border: const OutlineInputBorder(),
            ),
            onChanged: (_) {
              setState(() {
                _error = null;
              });
            },
          ),
          if (total != null) ...[
            const SizedBox(height: 12),
            Text(
              'Total: \$${total.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () {
              final q = int.tryParse(_controller.text.trim());
              if (q == null || q < 1) {
                setState(() => _error = 'Enter a valid quantity');
                return;
              }
              if (q < p.moq) {
                setState(
                  () => _error = 'Quantity must be at least MOQ (${p.moq})',
                );
                return;
              }
              if (!context.mounted) return;
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Order placed: ${p.name} × $q = \$${p.totalFor(t, q).toStringAsFixed(2)}',
                  ),
                ),
              );
            },
            child: const Text('Place order'),
          ),
        ],
      ),
    );
  }
}
