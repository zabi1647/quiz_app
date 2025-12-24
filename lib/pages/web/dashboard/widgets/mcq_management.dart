import 'package:flutter/material.dart';
import 'package:quiz_app/models/mcq_model.dart';
import 'package:quiz_app/services/firestore_service.dart';

class MCQManagement extends StatefulWidget {
  const MCQManagement({super.key});

  @override
  State<MCQManagement> createState() => _MCQManagementState();
}

class _MCQManagementState extends State<MCQManagement> {
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Column(
      children: [
        // Header with Add Button
        Container(
          padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
          color: Colors.white,
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search MCQs...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  onChanged: (value) {
                    setState(() => _searchQuery = value);
                  },
                ),
              ),
              SizedBox(width: isSmallScreen ? 8 : 16),
              ElevatedButton.icon(
                onPressed: () => _showAddEditDialog(context),
                icon: const Icon(Icons.add),
                label: Text(isSmallScreen ? 'Add' : 'Add MCQ'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple.shade600,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 16 : 24,
                    vertical: isSmallScreen ? 12 : 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ),
        // MCQ List
        Expanded(
          child: StreamBuilder<List<MCQModel>>(
            stream: _firestoreService.getMCQs(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              List<MCQModel> mcqs = snapshot.data ?? [];

              // Filter based on search
              if (_searchQuery.isNotEmpty) {
                mcqs = mcqs
                    .where(
                      (mcq) =>
                          mcq.question.toLowerCase().contains(
                            _searchQuery.toLowerCase(),
                          ) ||
                          mcq.category.toLowerCase().contains(
                            _searchQuery.toLowerCase(),
                          ),
                    )
                    .toList();
              }

              if (mcqs.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.quiz, size: 64, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      Text(
                        _searchQuery.isEmpty
                            ? 'No MCQs found. Add your first MCQ!'
                            : 'No MCQs match your search.',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
                itemCount: mcqs.length,
                itemBuilder: (context, index) {
                  final mcq = mcqs[index];
                  return _buildMCQCard(context, mcq, isSmallScreen);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMCQCard(BuildContext context, MCQModel mcq, bool isSmallScreen) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    mcq.question,
                    style: TextStyle(
                      fontSize: isSmallScreen ? 16 : 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      _showAddEditDialog(context, mcq: mcq);
                    } else if (value == 'delete') {
                      _showDeleteDialog(context, mcq);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'edit', child: Text('Edit')),
                    const PopupMenuItem(value: 'delete', child: Text('Delete')),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...mcq.options.asMap().entries.map((entry) {
              final isCorrect = entry.key == mcq.correctAnswerIndex;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Icon(
                      isCorrect
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      color: isCorrect ? Colors.green : Colors.grey,
                      size: isSmallScreen ? 18 : 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        entry.value,
                        style: TextStyle(
                          fontSize: isSmallScreen ? 14 : 16,
                          color: isCorrect ? Colors.green : Colors.black87,
                          fontWeight: isCorrect
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
            const Divider(height: 24),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Chip(
                  label: Text(mcq.category),
                  backgroundColor: Colors.blue.shade100,
                  labelStyle: const TextStyle(fontSize: 12),
                ),
                Chip(
                  label: Text(mcq.difficulty),
                  backgroundColor: _getDifficultyColor(mcq.difficulty),
                  labelStyle: const TextStyle(fontSize: 12),
                ),
                Chip(
                  label: Text('Attempts: ${mcq.attemptsCount}'),
                  avatar: const Icon(Icons.people, size: 16),
                  labelStyle: const TextStyle(fontSize: 12),
                ),
                Chip(
                  label: Text('Correct: ${mcq.correctCount}'),
                  avatar: const Icon(Icons.check, size: 16),
                  backgroundColor: Colors.green.shade100,
                  labelStyle: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return Colors.green.shade100;
      case 'medium':
        return Colors.orange.shade100;
      case 'hard':
        return Colors.red.shade100;
      default:
        return Colors.grey.shade100;
    }
  }

  void _showAddEditDialog(BuildContext context, {MCQModel? mcq}) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;
    showDialog(
      context: context,
      builder: (context) => _MCQDialog(mcq: mcq, isSmallScreen: isSmallScreen),
    );
  }

  void _showDeleteDialog(BuildContext context, MCQModel mcq) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete MCQ'),
        content: const Text('Are you sure you want to delete this MCQ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await _firestoreService.deleteMCQ(mcq.id!);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('MCQ deleted successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _MCQDialog extends StatefulWidget {
  final MCQModel? mcq;
  final bool isSmallScreen;

  const _MCQDialog({this.mcq, required this.isSmallScreen});

  @override
  State<_MCQDialog> createState() => _MCQDialogState();
}

class _MCQDialogState extends State<_MCQDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _questionController;
  late List<TextEditingController> _optionControllers;
  late String _category;
  late String _difficulty;
  late int _correctAnswerIndex;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _questionController = TextEditingController(
      text: widget.mcq?.question ?? '',
    );
    _optionControllers = List.generate(
      4,
      (index) => TextEditingController(
        text: (widget.mcq?.options.length ?? 0) > index
            ? widget.mcq!.options[index]
            : '',
      ),
    );
    _category = widget.mcq?.category ?? 'General';
    _difficulty = widget.mcq?.difficulty ?? 'Medium';
    _correctAnswerIndex = widget.mcq?.correctAnswerIndex ?? 0;
  }

  @override
  void dispose() {
    _questionController.dispose();
    for (var controller in _optionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: widget.isSmallScreen ? double.infinity : 600,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        padding: EdgeInsets.all(widget.isSmallScreen ? 16 : 24),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.mcq == null ? 'Add New MCQ' : 'Edit MCQ',
                  style: TextStyle(
                    fontSize: widget.isSmallScreen ? 20 : 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple.shade600,
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _questionController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Question',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Please enter a question' : null,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Options:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ..._optionControllers.asMap().entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Radio<int>(
                          value: entry.key,
                          groupValue: _correctAnswerIndex,
                          onChanged: (value) {
                            setState(() => _correctAnswerIndex = value!);
                          },
                        ),
                        Expanded(
                          child: TextFormField(
                            controller: entry.value,
                            decoration: InputDecoration(
                              labelText: 'Option ${entry.key + 1}',
                              border: const OutlineInputBorder(),
                            ),
                            validator: (value) => value?.isEmpty ?? true
                                ? 'Please enter option ${entry.key + 1}'
                                : null,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _category,
                        decoration: const InputDecoration(
                          labelText: 'Category',
                          border: OutlineInputBorder(),
                        ),
                        items:
                            [
                                  'General',
                                  'Science',
                                  'Math',
                                  'History',
                                  'Geography',
                                ]
                                .map(
                                  (cat) => DropdownMenuItem(
                                    value: cat,
                                    child: Text(cat),
                                  ),
                                )
                                .toList(),
                        onChanged: (value) =>
                            setState(() => _category = value!),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _difficulty,
                        decoration: const InputDecoration(
                          labelText: 'Difficulty',
                          border: OutlineInputBorder(),
                        ),
                        items: ['Easy', 'Medium', 'Hard']
                            .map(
                              (diff) => DropdownMenuItem(
                                value: diff,
                                child: Text(diff),
                              ),
                            )
                            .toList(),
                        onChanged: (value) =>
                            setState(() => _difficulty = value!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _handleSave,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple.shade600,
                        foregroundColor: Colors.white,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Save'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final mcq = MCQModel(
        id: widget.mcq?.id,
        question: _questionController.text,
        options: _optionControllers.map((c) => c.text).toList(),
        correctAnswerIndex: _correctAnswerIndex,
        category: _category,
        difficulty: _difficulty,
        attemptsCount: widget.mcq?.attemptsCount ?? 0,
        correctCount: widget.mcq?.correctCount ?? 0,
        incorrectCount: widget.mcq?.incorrectCount ?? 0,
      );

      if (widget.mcq == null) {
        await FirestoreService().addMCQ(mcq);
      } else {
        await FirestoreService().updateMCQ(widget.mcq!.id!, mcq);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.mcq == null
                  ? 'MCQ added successfully'
                  : 'MCQ updated successfully',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
