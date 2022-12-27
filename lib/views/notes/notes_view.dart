import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/constants/routes.dart';
import 'package:flutter_application_1/enums/menu_action.dart';
import 'package:flutter_application_1/my_widgets/progress_view.dart';
import 'package:flutter_application_1/services/auth/auth_service.dart';
import 'package:flutter_application_1/services/auth/bloc/auth_bloc.dart';
import 'package:flutter_application_1/services/auth/bloc/auth_event.dart';
import 'package:flutter_application_1/services/cloud/cloud_note.dart';
import 'package:flutter_application_1/services/cloud/firebase_cloud_storage.dart';
// import 'package:flutter_application_1/services/crud/notes_service.dart';
import 'package:flutter_application_1/utilities/dialogs/logout_dialog.dart';
import 'package:flutter_application_1/views/notes/service_categories_list_view.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  late final FirebaseCloudStorage _notesService;
  late final TextEditingController _search;

  String get userId => AuthService.firebase().currentUser!.id;

  @override
  void initState() {
    _search = TextEditingController();
    _notesService = FirebaseCloudStorage();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var size =
        MediaQuery.of(context).size; //here we take the size of the device
    return Scaffold(
        bottomNavigationBar: NavigationBar(
          onDestinationSelected: (index) {
            if (index == 0) {

            }else if (index == 1) {
              context.read<AuthBloc>().add(const AuthEventSeach());
            }
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(
                Icons.home,
                color: Colors.green,
              ),
              label: "home",
            ),
            NavigationDestination(
              icon: Icon(
                Icons.search,
                color: Colors.green,
              ),
              label: "search",
            ),
            NavigationDestination(
              icon: Icon(
                Icons.home,
                color: Colors.green,
              ),
              label: "home",
            ),
            NavigationDestination(
              icon: Icon(
                Icons.home,
                color: Colors.green,
              ),
              label: "home",
            ),
          ],
        ),
        appBar: AppBar(
          shadowColor: Colors.transparent,
          backgroundColor: Colors.white,
          actions: [
            IconButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(createOrUpdateNoteRoute);
                },
                icon: const Icon(Icons.search)),
            IconButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(createOrUpdateNoteRoute);
                },
                icon: const Icon(Icons.add)),
            PopupMenuButton<MenuAction>(
              onSelected: (value) async {
                switch (value) {
                  case MenuAction.logout:
                    final shouldLogout = await showLogOutDialog(context);
                    if (shouldLogout) {
                      context.read<AuthBloc>().add(const AuthEventLogOut());
                    }
                }
              },
              itemBuilder: (context) {
                return const [
                  PopupMenuItem<MenuAction>(
                    value: MenuAction.logout,
                    child: Text('log out'),
                  ),
                ];
              },
            )
          ],
        ),
        body: Stack(
          children: <Widget>[
            Container(
              height: size.height * .25,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  alignment: Alignment.center,
                  image: AssetImage("assets/images/banner.png"),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                  top: size.height * .25 + 5, left: 5, right: 5),
              child: StreamBuilder(
                stream: _notesService.allNotes(ownerUserId: userId),
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                      return progress;
                    case ConnectionState.active:
                      if (snapshot.hasData) {
                        final allNotes = snapshot.data as Iterable<CloudNote>;
                        log(allNotes.length.toString());
                        return ServiceCategoriesListView(
                          notes: allNotes,
                          onDeleteNote: (note) async {
                            await _notesService.deleteNote(
                                documentId: note.documentId);
                          },
                          onTap: (note) {
                            Navigator.of(context).pushNamed(
                              createOrUpdateNoteRoute,
                              arguments: note,
                            );
                          },
                        );
                      } else {
                        return progress;
                      }
                    default:
                      return progress;
                  }
                },
              ),
            )
          ],
        ));
  }
}
