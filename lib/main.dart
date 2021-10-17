import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:routemaster/routemaster.dart';

class User {
  String id;
  String name;
  User({required this.id, required this.name});
}

class AppState extends ChangeNotifier {
  User? _user;

  AppState() {
    initAppState();
    delayedInitAppState();
  }

  Future initAppState() async {
    user = await fetchUser();
  }

  Future delayedInitAppState() async {
    await Future.delayed(const Duration(seconds: 10));
    user = await Future.value(User(id: 'changed_id', name: 'changed_name'));
  }

  User? get user => _user;
  set user(User? u) {
    _user = u;
    notifyListeners();
  }
}

Future<User> fetchUser() async {
  await Future.delayed(const Duration(seconds: 3));
  return User(id: 'id', name: 'name');
}

class TopPage extends StatelessWidget {
  const TopPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Scaffold(
        body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("in root page  " + (state.user?.name ?? "un-fetched")),
        ElevatedButton(
            onPressed: () {
              Routemaster.of(context).push('/user/id');
            },
            child: const Text('to user page'))
      ],
    )));
  }
}

enum Display {
  profile,
  signup,
}

class UserPage extends StatefulWidget {
  String? id;
  UserPage({Key? key, this.id}) : super(key: key);

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  Display display = Display.signup;
  User? user;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final state = context.watch<AppState>();
    if (widget.id != state.user?.id) {
      print("widget.id != state.user?.id : ${widget.id} != ${state.user?.id}  ==> ${widget.id != state.user?.id}");
      WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
        Routemaster.of(context).push('/');
      });
      return;
    }

    setState(() {
      display = state.user == null ? Display.signup : Display.profile;
      user = state.user;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget child;
    switch (display) {
      case Display.signup:
        child = const Center(child: Text("you need sign up"));
        break;
      case Display.profile:
        child = Center(
            child: Text("your name is ${user?.name ?? "WOW SOMETHING ERROR"}"));
        break;
    }
    return Scaffold(body: child);
  }
}

final routes = RouteMap(routes: {
  "/": (_) => const MaterialPage(child: TopPage()),
  "/user/:id": (route) =>
      MaterialPage(child: UserPage(id: route.pathParameters['id'])),
});

void main() {
  runApp(ChangeNotifierProvider(
    create: (context) => AppState(),
    child: Consumer<AppState>(
      builder: (context, state, child) {
        return MaterialApp.router(
          routeInformationParser: const RoutemasterParser(),
          routerDelegate: RoutemasterDelegate(routesBuilder: (context) => routes)
        );
      },
    ),
  ));
}
