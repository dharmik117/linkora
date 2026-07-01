import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../providers/link_provider.dart';
import '../../providers/category_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/models/category_model.dart';

import '../../shared/widgets/link_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _selectedFilterCategoryId; // null means 'All'
  bool _isSearching = false;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final linkProvider = context.watch<LinkProvider>();
    final categoryProvider = context.watch<CategoryProvider>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Search title, description, url...',
                  hintStyle: TextStyle(color: Colors.white54),
                  border: InputBorder.none,
                ),
                onChanged: (value) => setState(() => _searchQuery = value),
              )
            : const Text(
                'Linkora',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search, color: Colors.white),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  _searchQuery = '';
                }
              });
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            const Text(
              'Your Links',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 16),
            // Categories Horizontal List
            SizedBox(
              height: 40,
              child: categoryProvider.categories.isEmpty 
                ? ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _buildCategoryChip(
                        'All', 
                        isSelected: _selectedFilterCategoryId == null,
                        onTap: () => setState(() => _selectedFilterCategoryId = null),
                      ),
                      _buildCategoryChip('+ New', onTap: () => _showAddCategoryDialog(context)),
                    ],
                  )
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: categoryProvider.categories.length + 2,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return _buildCategoryChip(
                          'All', 
                          isSelected: _selectedFilterCategoryId == null,
                          onTap: () => setState(() => _selectedFilterCategoryId = null),
                        );
                      }
                      if (index == 1) {
                        return _buildCategoryChip('+ New', onTap: () => _showAddCategoryDialog(context));
                      }
                      final category = categoryProvider.categories[index - 2];
                      return _buildCategoryChip(
                        category.name,
                        isSelected: _selectedFilterCategoryId == category.id,
                        onTap: () => setState(() => _selectedFilterCategoryId = category.id),
                      );
                    },
                  ),
            ),
            const SizedBox(height: 24),
            // Links List
            Expanded(
              child: linkProvider.isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppTheme.accentNeonGreen))
                  : linkProvider.links.isEmpty
                      ? const Center(
                          child: Text(
                            'No links saved yet.\nTap + to add one!',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white54, fontSize: 16),
                          ),
                        )
                      : Builder(
                          builder: (context) {
                            var filteredLinks = _selectedFilterCategoryId == null
                                ? linkProvider.links.where((l) => !l.isLocked).toList()
                                : linkProvider.links.where((l) => !l.isLocked && l.categoryId == _selectedFilterCategoryId).toList();
                            
                            if (_searchQuery.trim().isNotEmpty) {
                              final query = _searchQuery.trim().toLowerCase();
                              filteredLinks = filteredLinks.where((l) {
                                return l.title.toLowerCase().contains(query) ||
                                       l.description.toLowerCase().contains(query) ||
                                       l.url.toLowerCase().contains(query);
                              }).toList();
                            }
                                
                            if (filteredLinks.isEmpty) {
                              return const Center(
                                child: Text(
                                  'No links in this category.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.white54, fontSize: 16),
                                ),
                              );
                            }
                            
                            return ReorderableListView.builder(
                              buildDefaultDragHandles: false,
                              padding: const EdgeInsets.only(top: 16, bottom: 100),
                              itemCount: filteredLinks.length,
                              onReorder: (oldIndex, newIndex) {
                                context.read<LinkProvider>().reorderLinks(oldIndex, newIndex);
                              },
                              proxyDecorator: (Widget child, int index, Animation<double> animation) {
                                return AnimatedBuilder(
                                  animation: animation,
                                  builder: (BuildContext context, Widget? child) {
                                    final double elevation = Tween<double>(begin: 0, end: 12).evaluate(animation);
                                    final double scale = Tween<double>(begin: 1, end: 1.02).evaluate(animation);
                                    return Transform.scale(
                                      scale: scale,
                                      child: Material(
                                        color: Colors.transparent,
                                        elevation: elevation,
                                        shadowColor: AppTheme.accentNeonGreen.withAlpha(100),
                                        borderRadius: BorderRadius.circular(24),
                                        child: child,
                                      ),
                                    );
                                  },
                                  child: child,
                                );
                              },
                              itemBuilder: (context, index) {
                                final link = filteredLinks[index];
                                return Container(
                                  key: ValueKey(link.id),
                                  margin: const EdgeInsets.only(bottom: 16),
                                  child: LinkCard(link: link, linkProvider: linkProvider, index: index),
                                );
                              },
                            );
                          }
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String label, {bool isSelected = false, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.accentNeonGreen : AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.black : Colors.white,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  void _showAddCategoryDialog(BuildContext context) {
    final nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppTheme.surfaceColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text('New Category', style: TextStyle(color: Colors.white)),
          content: TextField(
            controller: nameController,
            autofocus: true,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'e.g. Flutter, Work, Recipes',
              hintStyle: const TextStyle(color: Colors.white38),
              filled: true,
              fillColor: Colors.white10,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
            ),
            ElevatedButton(
              onPressed: () {
                final name = nameController.text.trim();
                if (name.isNotEmpty) {
                  final category = CategoryModel(
                    id: const Uuid().v4(),
                    name: name,
                  );
                  context.read<CategoryProvider>().addCategory(category);
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentNeonGreen,
                foregroundColor: Colors.black,
              ),
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }
}
