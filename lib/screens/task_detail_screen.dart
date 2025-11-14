import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class TaskDetailScreen extends StatefulWidget {
  final Map<String, dynamic> task;

  const TaskDetailScreen({super.key, required this.task});

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  final _descriptionController = TextEditingController();
  bool _isSubmitting = false;
  File? _imageFile;

  Future<void> _pickImageFromCamera() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تصویر با موفقیت انتخاب شد')),
      );
    }
  }

  void _submitTaskUpdate() async {
    setState(() => _isSubmitting = true);

    // در آینده: ارسال به سرور
    await Future.delayed(const Duration(seconds: 1));

    setState(() => _isSubmitting = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('اطلاعات با موفقیت ثبت شد')),
    );
  }

  void _markTaskAsCompleted() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('اعلام پایان تسک هنوز پیاده‌سازی نشده')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final task = widget.task;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('جزئیات تسک')),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: [
              Text('عنوان: ${task['title']}', style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 8),
              Text('توضیحات: ${task['description'] ?? '---'}'),
              const SizedBox(height: 16),
              Text('وضعیت: ${task['status']}'),
              const SizedBox(height: 16),
              TextField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'توضیحات جدید',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                icon: const Icon(Icons.camera_alt),
                label: const Text('گرفتن تصویر با دوربین'),
                onPressed: _pickImageFromCamera,
              ),
              if (_imageFile != null) ...[
                const SizedBox(height: 12),
                Image.file(_imageFile!, height: 150),
              ],
              const SizedBox(height: 16),
              ElevatedButton.icon(
                icon: const Icon(Icons.check),
                label: const Text('اعلام پایان تسک'),
                onPressed: _markTaskAsCompleted,
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                icon: const Icon(Icons.send),
                label: const Text('ارجاع به مدیر'),
                onPressed: _isSubmitting ? null : _submitTaskUpdate,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
