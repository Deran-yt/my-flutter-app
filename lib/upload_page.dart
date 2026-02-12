import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'widgets/animated_action_button.dart';

class UploadPage extends StatefulWidget {
  const UploadPage({super.key});

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> with SingleTickerProviderStateMixin {
  final List<File> _selectedFiles = [];
  final List<String> _fileNames = [];
  double _progress = 0.0;
  bool _uploading = false;
  bool _uploadComplete = false;
  late AnimationController _checkmarkCtrl;

  @override
  void initState() {
    super.initState();
    _checkmarkCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
  }

  @override
  void dispose() {
    _checkmarkCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowMultiple: true, allowedExtensions: ['png', 'jpg', 'jpeg', 'pdf']);
    if (result == null) return;
    for (var file in result.files) {
      if (file.size > 5 * 1024 * 1024) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('One or more files too large (max 5MB)')));
        return;
      }
    }
    setState(() {
      for (var file in result.files) {
        _fileNames.add(file.name);
        _selectedFiles.add(File(file.path!));
      }
    });
  }

  Future<void> _startUpload() async {
    if (_selectedFiles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select files first')));
      return;
    }
    setState(() {
      _uploading = true;
      _progress = 0.0;
    });

    // Simulate upload per file
    for (var i = 0; i < _selectedFiles.length; i++) {
      for (var t = 1; t <= 20; t++) {
        await Future.delayed(const Duration(milliseconds: 80));
        setState(() => _progress = ((i / _selectedFiles.length) + (t / 20) / _selectedFiles.length));
      }
    }

    setState(() {
      _uploading = false;
      _progress = 0.0;
      _uploadComplete = true;
    });

    _checkmarkCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 1500));

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Text('Upload complete'),
      action: SnackBarAction(label: 'Undo', onPressed: () {
        setState(() {
          _selectedFiles.clear();
          _fileNames.clear();
          _uploadComplete = false;
          _checkmarkCtrl.reset();
        });
      }),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Upload Notes"), backgroundColor: const Color(0xFF3F51B5)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DragTarget<List<File>>(
                onAcceptWithDetails: (details) {
                  // Basic drag-drop placeholder (platform-specific drag-drop would require native support)
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Drag-drop detected (use Select Files button to pick)')));
                },
                builder: (context, accepted, rejected) {
                  return Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      border: Border.all(color: accepted.isEmpty ? Colors.grey : Colors.blue, width: 2),
                      borderRadius: BorderRadius.circular(12),
                      color: accepted.isEmpty ? Colors.grey.shade50 : Colors.blue.shade50,
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.cloud_upload, size: 48, color: accepted.isEmpty ? Colors.grey : Colors.blue),
                        const SizedBox(height: 12),
                        const Text('Drag files here or use button below'),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _pickFile,
                      icon: const Icon(Icons.attach_file),
                      label: const Text('Select Files'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3F51B5),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 6,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFF3F51B5), Color(0xFF673AB7)]),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.purple.withOpacity(0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: AnimatedActionButton(
                      onPressed: _startUpload,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        child: const Icon(Icons.cloud_upload, color: Colors.white, size: 24),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              if (_selectedFiles.isNotEmpty) ...[
              SizedBox(
                height: 120,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _selectedFiles.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, i) {
                    final name = _fileNames[i];
                    final file = _selectedFiles[i];
                    final lower = name.toLowerCase();
                    Widget preview;
                    if (lower.endsWith('.pdf')) {
                      preview = Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.picture_as_pdf, size: 44, color: Colors.red),
                          const SizedBox(height: 6),
                          SizedBox(width: 120, child: Text(name, overflow: TextOverflow.ellipsis)),
                        ],
                      );
                    } else {
                      preview = Image.file(file, width: 120, height: 120, fit: BoxFit.cover);
                    }
                    return Stack(
                      children: [
                        Container(width: 120, height: 120, decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: Colors.grey.shade200), child: preview),
                        Positioned(
                          right: 2,
                          top: 2,
                          child: GestureDetector(
                            onTap: () => setState(() {
                              _selectedFiles.removeAt(i);
                              _fileNames.removeAt(i);
                            }),
                            child: Container(
                              decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.black54),
                              padding: const EdgeInsets.all(4),
                              child: const Icon(Icons.close, size: 16, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
            ],
            if (_uploading)
              Column(children: [LinearProgressIndicator(value: _progress), const SizedBox(height: 8), Text('${(_progress * 100).toStringAsFixed(0)}%')])
            else if (_uploadComplete)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: ScaleTransition(
                    scale: CurvedAnimation(parent: _checkmarkCtrl, curve: Curves.elasticOut),
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.green.shade100),
                      child: const Icon(Icons.check, size: 60, color: Colors.green),
                    ),
                  ),
                ),
              )
            else
              const SizedBox.shrink(),
          ],
        ),
      ),
    ));
  }
}
