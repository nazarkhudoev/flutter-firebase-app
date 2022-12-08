import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/my_widgets/progress_view.dart';
import 'package:flutter_application_1/services/auth/auth_service.dart';
// import 'package:flutter_application_1/services/crud/notes_service.dart';
import 'package:flutter_application_1/utilities/generics/get_arguments.dart';
import 'package:flutter_application_1/services/cloud/cloud_note.dart';
import 'package:flutter_application_1/services/cloud/cloud_storage_exceptions.dart';
import 'package:flutter_application_1/services/cloud/firebase_cloud_storage.dart';

class CreateUpdateNoteView extends StatefulWidget {
  const CreateUpdateNoteView({super.key});

  @override
  State<CreateUpdateNoteView> createState() => _CreateUpdateNoteViewState();
}

class _CreateUpdateNoteViewState extends State<CreateUpdateNoteView> {
  CloudNote? _note;
  late final FirebaseCloudStorage _notesService;
  late final TextEditingController _textEditingController;

  @override
  void initState() {
    _notesService = FirebaseCloudStorage();
    _textEditingController = TextEditingController();
    super.initState();
  }

  void _textControllerListener() async {
    final note = _note;
    if (note == null) {
      return;
    }

    final text = _textEditingController.text;
    await _notesService.updateNote(
      documentId: note.documentId,
      text: text,
    );
  }

  void _setupTextControllerListener() {
    _textEditingController.removeListener(_textControllerListener);
    _textEditingController.addListener(_textControllerListener);
  }

  Future<CloudNote> _createOrGetExistingNote(BuildContext context) async {
    final widgetNote = context.getArgument<CloudNote>();

    if (widgetNote != null) {
      _note = widgetNote;
      _textEditingController.text = widgetNote.text;
      return widgetNote;
    }

    final existingNote = _note;
    if (existingNote != null) return existingNote;

    final currentUser = AuthService.firebase().currentUser!;
    final userId = currentUser.id;
    // final owner = await _notesService.getUser(email: email);
    final newNote = await _notesService.createNewNote(ownerUserId: userId);
    _note = newNote;
    return newNote;
  }

  void _deleteNoteIfTextIdEmpty() {
    final note = _note;
    if (_textEditingController.text.isEmpty && note != null) {
      _notesService.deleteNote(documentId: note.documentId);
    }
  }

  void _saveNoteIfTextNotEmpty() async {
    final note = _note;
    final text = _textEditingController.text;
    if (note != null && text.isNotEmpty) {
      await _notesService.updateNote(
        documentId: note.documentId,
        text: text,
      );
    }
  }

  @override
  void dispose() {
    _deleteNoteIfTextIdEmpty();
    _saveNoteIfTextNotEmpty();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Note')),
      body: FutureBuilder(
        future: _createOrGetExistingNote(context),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              _setupTextControllerListener();
              return TextField(
                controller: _textEditingController,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                decoration: const InputDecoration(
                    hintText: 'Start typing your note...'),
              );
            default:
              return progress;
          }
        },
      ),
    );
  }
}
