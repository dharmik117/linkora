import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/services/metadata_service.dart';
import '../../../data/local/hive_service.dart';
import '../../../domain/models/link_model.dart';
import '../../providers/link_provider.dart';
import '../../providers/category_provider.dart';
import '../../shared/widgets/rating_dialog.dart';

class AddLinkBottomSheet extends StatefulWidget {
  final LinkModel? existingLink;
  final String? initialUrl;

  const AddLinkBottomSheet({super.key, this.existingLink, this.initialUrl});

  static Future<void> show(BuildContext context, {LinkModel? existingLink, String? initialUrl}) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => AddLinkBottomSheet(existingLink: existingLink, initialUrl: initialUrl),
    );
    
    if (context.mounted) {
      try {
        final hiveService = context.read<HiveService>();
        final count = hiveService.linksSavedCount;
        if (!hiveService.hasRatedApp && !hiveService.declinedRating) {
          if (count == 3 || (count > 3 && count % 5 == 0)) {
            RatingDialog.show(context);
          }
        }
      } catch (_) {}
    }
  }

  @override
  State<AddLinkBottomSheet> createState() => _AddLinkBottomSheetState();
}

class _AddLinkBottomSheetState extends State<AddLinkBottomSheet> {
  final _urlController = TextEditingController();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  String? _selectedCategoryId;
  bool _isLoading = false;
  bool _isFetchingMetadata = false;
  String? _fetchedImageUrl; // Store fetched image
  String? _urlError;

  @override
  void initState() {
    super.initState();
    if (widget.existingLink != null) {
      _urlController.text = widget.existingLink!.url;
      _titleController.text = widget.existingLink!.title;
      _descriptionController.text = widget.existingLink!.description;
      _selectedCategoryId = widget.existingLink!.categoryId;
      _fetchedImageUrl = widget.existingLink!.previewImageUrl;
    } else if (widget.initialUrl != null) {
      _urlController.text = widget.initialUrl!;
      _fetchPreview(); // Auto fetch preview for shared links
    }
  }

  @override
  void dispose() {
    _urlController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  bool _validateUrl() {
    var url = _urlController.text.trim();
    if (url.isEmpty) {
      setState(() => _urlError = 'URL cannot be empty');
      return false;
    }
    
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'https://$url';
      _urlController.text = url;
    }
    
    final uri = Uri.tryParse(url);
    if (uri == null || !uri.hasAuthority || uri.host.isEmpty || !uri.host.contains('.')) {
      setState(() => _urlError = 'Please enter a valid URL');
      return false;
    }
    
    setState(() => _urlError = null);
    return true;
  }

  Future<void> _fetchPreview() async {
    if (!_validateUrl()) return;
    final url = _urlController.text.trim();

    setState(() => _isFetchingMetadata = true);

    final metadataService = MetadataService();
    final metadata = await metadataService.fetch(url);

    if (metadata != null) {
      if (metadata.title != null && _titleController.text.isEmpty) {
        _titleController.text = metadata.title!;
      }
      if (metadata.description != null && _descriptionController.text.isEmpty) {
        _descriptionController.text = metadata.description!;
      }
      if (metadata.image != null && metadata.image!.isNotEmpty) {
        _fetchedImageUrl = metadata.image;
      }
    }
    
    setState(() => _isFetchingMetadata = false);
  }

  Future<void> _saveLink() async {
    if (!_validateUrl()) return;
    final url = _urlController.text.trim();

    setState(() => _isLoading = true);

    final metadataService = MetadataService();
    final domain = metadataService.extractDomain(url);
    
    var finalTitle = _titleController.text.trim();
    var finalDesc = _descriptionController.text.trim();

    // ALWAYS fetch metadata if we don't have an image yet, to ensure rich previews work
    if (finalTitle.isEmpty || finalDesc.isEmpty || _fetchedImageUrl == null) {
      final metadata = await metadataService.fetch(url);
      if (finalTitle.isEmpty) finalTitle = metadata?.title ?? domain;
      if (finalDesc.isEmpty) finalDesc = metadata?.description ?? 'No description available.';
      if (metadata?.image != null && metadata!.image!.isNotEmpty) {
        _fetchedImageUrl = metadata.image;
      }
    }

    if (widget.existingLink != null) {
      final updatedLink = widget.existingLink!.copyWith(
        url: url,
        title: finalTitle.isNotEmpty ? finalTitle : domain,
        description: finalDesc,
        previewImageUrl: _fetchedImageUrl ?? widget.existingLink!.previewImageUrl,
        domainName: domain,
        categoryId: _selectedCategoryId,
      );
      if (mounted) {
        context.read<LinkProvider>().updateLink(updatedLink);
        Navigator.pop(context); // Close the sheet
      }
    } else {
      final newLink = LinkModel(
        id: const Uuid().v4(),
        url: url,
        title: finalTitle.isNotEmpty ? finalTitle : domain,
        description: finalDesc,
        previewImageUrl: _fetchedImageUrl,
        faviconUrl: null,
        domainName: domain,
        categoryId: _selectedCategoryId,
        createdAt: DateTime.now(),
        lastOpenedAt: DateTime.now(),
      );

      if (mounted) {
        context.read<LinkProvider>().addLink(newLink);
        await context.read<HiveService>().incrementLinksSavedCount();
        if (mounted) Navigator.pop(context); // Close the sheet
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.existingLink != null ? 'Edit Link' : 'Save a new link',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _urlController,
                      autofocus: true,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'https://example.com',
                        hintStyle: const TextStyle(color: Colors.white38),
                        filled: true,
                        fillColor: Colors.white10,
                        errorText: _urlError,
                        errorStyle: const TextStyle(color: Colors.redAccent),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: const Icon(Icons.link, color: Colors.white54),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.accentSoftPurple),
                    ),
                    child: IconButton(
                      icon: _isFetchingMetadata 
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.accentSoftPurple))
                        : const Icon(Icons.auto_awesome, color: AppTheme.accentSoftPurple),
                      onPressed: _isFetchingMetadata ? null : _fetchPreview,
                      tooltip: 'Auto-fill from URL',
                    ),
                  )
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _titleController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Title (Optional)',
                  hintStyle: const TextStyle(color: Colors.white38),
                  filled: true,
                  fillColor: Colors.white10,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _descriptionController,
                style: const TextStyle(color: Colors.white),
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: 'Short Description (Optional)',
                  hintStyle: const TextStyle(color: Colors.white38),
                  filled: true,
                  fillColor: Colors.white10,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Category',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Consumer<CategoryProvider>(
                builder: (context, categoryProvider, child) {
                  if (categoryProvider.categories.isEmpty) {
                    return const Text(
                      'No categories created yet.',
                      style: TextStyle(color: Colors.white38),
                    );
                  }
                  return SizedBox(
                    height: 40,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: categoryProvider.categories.length,
                      itemBuilder: (context, index) {
                        final category = categoryProvider.categories[index];
                        final isSelected = _selectedCategoryId == category.id;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              // Toggle selection
                              _selectedCategoryId = isSelected ? null : category.id;
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? AppTheme.accentNeonGreen : Colors.white10,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Center(
                              child: Text(
                                category.name,
                                style: TextStyle(
                                  color: isSelected ? Colors.black : Colors.white,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveLink,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentNeonGreen,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.black,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Save Link',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
