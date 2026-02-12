import 'dart:async';

import 'package:flutter/material.dart';

import 'models/note.dart';
import 'widgets/animated_action_button.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  final List<Note> _notes = List.generate(
    8,
    (i) => Note(
      id: 'n$i',
      title: 'Note ${i + 1}',
      content: 'This is the content for note ${i + 1}.',
      category: i % 3 == 0 ? 'Math' : (i % 3 == 1 ? 'Physics' : 'Chemistry'),
      timestamp: DateTime.now().subtract(Duration(minutes: i * 7)),
    ),
  );

  final List<String> _categories = ['All', 'Math', 'Physics', 'Chemistry'];
  String _activeCategory = 'All';
  String _search = '';
  late final AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  List<Note> get _filteredNotes {
    var list = _notes.where((n) => _activeCategory == 'All' ? true : n.category == _activeCategory).toList();
    if (_search.isNotEmpty) {
      list = list.where((n) => n.title.toLowerCase().contains(_search.toLowerCase())).toList();
    }
    return list;
  }

  List<String> get _suggestions {
    if (_search.isEmpty) return [];
    return _notes.map((n) => n.title).where((t) => t.toLowerCase().contains(_search.toLowerCase())).toSet().toList();
  }

  Future<void> _refresh() async {
    await Future.delayed(const Duration(milliseconds: 700));
    setState(() {
      _notes.insert(
        0,
        Note(
          id: 'n_new',
          title: 'New Note',
          content: 'Newly fetched note content.',
          category: 'Math',
          timestamp: DateTime.now(),
        ),
      );
    });
  }

  void _toggleFavorite(Note n) {
    setState(() => n.favorite = !n.favorite);
  }

  void _showPreview(Note n) {
    showModalBottomSheet(
      context: context,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(n.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(n.content),
            const SizedBox(height: 12),
            Text('Category: ${n.category}'),
            const SizedBox(height: 12),
            Text('Updated: ${n.timestamp}'),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final suggestions = _notes.map((n) => n.title).where((t) => t.toLowerCase().contains(_search.toLowerCase())).toList();

    return Scaffold(
      appBar: AppBar(title: const Text("Home"), backgroundColor: const Color(0xFF3F51B5)),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Stack(
                      children: [
                        TextField(
                          decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Search notes...'),
                          onChanged: (v) => setState(() => _search = v),
                        ),
                        if (_suggestions.isNotEmpty)
                          Positioned(
                            top: 50,
                            left: 0,
                            right: 0,
                            child: Container(
                              constraints: const BoxConstraints(maxHeight: 150),
                              decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(8)),
                              child: ListView.builder(
                                itemCount: _suggestions.length,
                                itemBuilder: (_, i) => ListTile(
                                  dense: true,
                                  title: Text(_suggestions[i]),
                                  onTap: () => setState(() => _search = _suggestions[i]),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  AnimatedActionButton(
                    onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Create note'))),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF3F51B5), Color(0xFF673AB7)]), borderRadius: BorderRadius.circular(10)),
                      child: const Icon(Icons.add, color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 36,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _categories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, i) {
                    final cat = _categories[i];
                    return ChoiceChip(
                      label: Text(cat),
                      selected: _activeCategory == cat,
                      onSelected: (_) => setState(() => _activeCategory = cat),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.builder(
                  itemCount: _filteredNotes.length,
                  itemBuilder: (context, idx) {
                    final note = _filteredNotes[idx];
                    return Dismissible(
                      key: ValueKey(note.id),
                      background: Container(color: Colors.red, alignment: Alignment.centerLeft, padding: const EdgeInsets.only(left: 16), child: const Icon(Icons.delete, color: Colors.white)),
                      secondaryBackground: Container(color: Colors.green, alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 16), child: const Icon(Icons.favorite, color: Colors.white)),
                      onDismissed: (direction) {
                        setState(() {
                          _notes.removeWhere((n) => n.id == note.id);
                        });
                        if (direction == DismissDirection.startToEnd) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Note deleted')));
                        } else {
                          _toggleFavorite(note);
                        }
                      },
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: 1),
                        duration: Duration(milliseconds: 300 + (idx * 40)),
                        builder: (context, v, ch) => Opacity(opacity: v, child: Transform.translate(offset: Offset(0, 30 * (1 - v)), child: ch)),
                        child: Card(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: ListTile(
                            onTap: () => _showPreview(note),
                            leading: CircleAvatar(child: Text(note.category[0])),
                            title: Text(note.title),
                            subtitle: Text('${note.category} • ${note.timestamp.hour}:${note.timestamp.minute.toString().padLeft(2, '0')}'),
                            trailing: IconButton(
                              icon: Icon(note.favorite ? Icons.favorite : Icons.favorite_border, color: note.favorite ? Colors.red : null),
                              onPressed: () => _toggleFavorite(note),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
