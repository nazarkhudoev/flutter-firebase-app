import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/constants/routes.dart';
import 'package:flutter_application_1/enums/menu_action.dart';
import 'package:flutter_application_1/extentions/lists/filter.dart';
import 'package:flutter_application_1/my_widgets/progress_view.dart';
import 'package:flutter_application_1/services/auth/auth_service.dart';
import 'package:flutter_application_1/services/auth/bloc/auth_bloc.dart';
import 'package:flutter_application_1/services/auth/bloc/auth_event.dart';
import 'package:flutter_application_1/services/cloud/cloud_note.dart';
import 'package:flutter_application_1/services/cloud/firebase_cloud_storage.dart';
// import 'package:flutter_application_1/services/crud/notes_service.dart';
import 'package:flutter_application_1/utilities/dialogs/logout_dialog.dart';
import 'package:flutter_application_1/views/notes/service_list_view.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SearchView extends StatefulWidget {
  const SearchView({super.key});
  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  late final FirebaseCloudStorage _notesService;
  late final TextEditingController _searchController;

  String get userId => AuthService.firebase().currentUser!.id;

  List<CloudNote> _notes = [];

  List<CloudNote> _servicesList = [];

  void _textControllerListener() {
    final searchText = _searchController.text;

    setState(() {
      _servicesList = _notes
          .where((element) =>
              element.text.toLowerCase().contains(searchText.toLowerCase()))
          .toList();
    });

    log(searchText);
  }

  void _setupTextControllerListener() {
    _searchController.removeListener(_textControllerListener);
    _searchController.addListener(_textControllerListener);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    _notesService = FirebaseCloudStorage();
    _searchController = TextEditingController();
    _setupTextControllerListener();

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
              context.read<AuthBloc>().add(const AuthEventHome());
            } else if (index == 1) {}
          },
          selectedIndex: 1,
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
              height: size.height * .20,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    const Text(
                      "Search for a Service",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(
                      height: 20.0,
                    ),
                    TextField(
                      controller: _searchController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.green,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide.none,
                        ),
                        hintText: "eg: Plumber",
                        prefixIcon: const Icon(Icons.search),
                        prefixIconColor: Colors.green.shade900,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                  top: size.height * .20 + 5, left: 5, right: 5),
              child: StreamBuilder(
                stream: _notesService.allNotes(
                    ownerUserId: userId), // _notesService.searchNotes(
                // ownerUserId: userId, searchText: _searchController.text),
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                      return progress;
                    case ConnectionState.active:
                      if (snapshot.hasData) {
                        final allNotes = snapshot.data as Iterable<CloudNote>;
                        if (_notes.isEmpty) {
                          _notes.addAll(allNotes.toList());
                        }
                        log(allNotes.length.toString());
                        return ServiceListView(
                          notes: _servicesList,
                          onDeleteNote: (note) async {
                            await _notesService.deleteNote(
                                documentId: note.documentId);
                          },
                          onTap: (note) {
                            // Navigator.of(context).pushNamed(
                            //   createOrUpdateNoteRoute,
                            //   arguments: note,
                            // );
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
