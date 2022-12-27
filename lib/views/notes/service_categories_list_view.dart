import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/cloud/cloud_note.dart';
// import 'package:flutter_application_1/services/crud/notes_service.dart';
import 'package:flutter_application_1/utilities/dialogs/delete_dialog.dart';

typedef NoteCallback = void Function(CloudNote note);

class ServiceCategoriesListView extends StatelessWidget {
  final Iterable<CloudNote> notes;
  final NoteCallback onDeleteNote;
  final NoteCallback onTap;

  const ServiceCategoriesListView({
    Key? key,
    required this.notes,
    required this.onDeleteNote,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes.elementAt(index);

        return GestureDetector(
          onTap: () => onTap(note),
          child: Card(
            elevation: 10,
            color: Theme.of(context).colorScheme.surfaceVariant,
            shadowColor: Colors.transparent,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Image.asset(
                  'assets/images/humer.png',
                  width: 40,
                  height: 60,
                ),
                Text(note.text),
              ],
            ),
          ),
        );
        // return ListTile(
        //   onTap: () {
        //     onTap(note);
        //   },
        //   title: Text(
        //     note.text,
        //     maxLines: 1,
        //     softWrap: true,
        //     overflow: TextOverflow.ellipsis,
        //   ),
        //   trailing: IconButton(
        //     onPressed: () async {
        //       final shouldDelete = await showDeleteDialog(context);
        //       if (shouldDelete) {
        //         onDeleteNote(note);
        //       }
        //     },
        //     icon: const Icon(Icons.delete),
        //   ),
        // );
      },
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 5.0,
        mainAxisSpacing: 5.0,
      ),
    );
  }
  // @override
  // Widget build(BuildContext context) {
  //   return ListView.builder(
  //     itemCount: notes.length,
  //     itemBuilder: (context, index) {
  //       final note = notes.elementAt(index);
  //       return ListTile(
  //         onTap: () {
  //           onTap(note);
  //         },
  //         title: Text(
  //           note.text,
  //           maxLines: 1,
  //           softWrap: true,
  //           overflow: TextOverflow.ellipsis,
  //         ),
  //         trailing: IconButton(
  //           onPressed: () async {
  //             final shouldDelete = await showDeleteDialog(context);
  //             if (shouldDelete) {
  //               onDeleteNote(note);
  //             }
  //           },
  //           icon: const Icon(Icons.delete),
  //         ),
  //       );
  //     },
  //   );
  // }
}
