// Lead Genius Admin - Lista de Produtos
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../main.dart';
import '../../../models/product_model.dart';
import '../../../widgets/loading_widget.dart';
import '../../../widgets/modal_confirm.dart';

class ProductListPage extends ConsumerStatefulWidget {
  const ProductListPage({super.key});
  @override
  ConsumerState<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends ConsumerState<ProductListPage> {
  List<ProductModel> _products = [];
  bool _isLoading = true;

  @override
  void initState() { super.initState(); _loadProducts(); }

  Future<void> _loadProducts() async {
    setState(() => _isLoading = true);
    try {
      final response = await supabase.from('products').select().order('created_at', ascending: false);
      setState(() { _products = (response as List).map((e) => ProductModel.fromJson(e)).toList(); _isLoading = false; });
    } catch (e) { setState(() => _isLoading = false); }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    return Scaffold(
      appBar: AppBar(title: const Text('Produtos'), actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _loadProducts)]),
      floatingActionButton: FloatingActionButton.extended(onPressed: () => context.push('/client/products/new'), icon: const Icon(Icons.add), label: const Text('Novo Produto')),
      body: _isLoading ? const LoadingWidget() : _products.isEmpty
          ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.inventory_2_outlined, size: 64, color: theme.colorScheme.primary.withOpacity(0.3)),
              const SizedBox(height: 16), Text('Nenhum produto cadastrado', style: theme.textTheme.titleMedium),
            ]))
          : RefreshIndicator(
              onRefresh: _loadProducts,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _products.length,
                itemBuilder: (context, index) {
                  final product = _products[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: CircleAvatar(backgroundColor: theme.colorScheme.primary.withOpacity(0.1), child: Icon(Icons.inventory_2, color: theme.colorScheme.primary)),
                      title: Text(product.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text('Estoque: ${product.stock}\n${currencyFormat.format(product.price)}'),
                      isThreeLine: true,
                      trailing: PopupMenuButton(
                        itemBuilder: (context) => [
                          const PopupMenuItem(value: 'edit', child: Text('Editar')),
                          const PopupMenuItem(value: 'delete', child: Text('Excluir', style: TextStyle(color: Colors.red))),
                        ],
                        onSelected: (value) async {
                          if (value == 'edit') context.push('/client/products/${product.id}/edit');
                          if (value == 'delete') {
                            final confirmed = await showConfirmDialog(context, title: 'Excluir', message: 'Deseja excluir "${product.name}"?', isDanger: true);
                            if (confirmed == true) { await supabase.from('products').delete().eq('id', product.id); _loadProducts(); }
                          }
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
