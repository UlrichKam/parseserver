import 'dart:async';
import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';
import 'package:parseserver/providers/auth_provider.dart';
import 'package:parseserver/screens/home.dart';
import 'package:parseserver/screens/login.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  const keyApplicationId = 'xhNZn3puQ7v0JNzr31RsJnvFIQ6J6PUJobAhcPhQ';
  const keyClientKey = 'WXb2LGM9h2ie6PjW9sdRnEfO08n3TlYjKEDxeT8r';
  const keyParseServerUrl = 'https://parseapi.back4app.com';

  await Parse().initialize(keyApplicationId, keyParseServerUrl,
      clientKey: keyClientKey, autoSendSessionId: true);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => Auth()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Parse Server',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const Authentication(),
    );
  }
}

class Authentication extends StatefulWidget {
  const Authentication({Key? key}) : super(key: key);

  @override
  State<Authentication> createState() => _AuthenticationState();
}

class _AuthenticationState extends State<Authentication> {
  Future<ParseUser?> hasUserLogged() async {
    ParseUser? currentUser = await ParseUser.currentUser() as ParseUser?;
    if (currentUser == null) {
      return null;
    }
    //Checks whether the user's session token is valid
    final ParseResponse? parseResponse =
    await ParseUser.getCurrentUserFromServer(currentUser.sessionToken!);

    if (parseResponse?.success == null || !parseResponse!.success) {
      //Invalid session. Logout
      await currentUser.logout();
      return null;
    } else {
      return currentUser;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: FutureBuilder<ParseUser?>(
          future: hasUserLogged(),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.waiting:
                return const Scaffold(
                  body: Center(
                    child: SizedBox(
                        width: 70,
                        height: 70,
                        child: CircularProgressIndicator()),
                  ),
                );
              default:
                if (snapshot.data != null) {
                  WidgetsBinding.instance?.addPostFrameCallback((_) {
                    context
                        .read<Auth>()
                        .authenticate(snapshot.data as ParseUser);
                  });

                  // Navigator.pushReplacement(
                  //     context,
                  //     MaterialPageRoute(
                  //         builder: (BuildContext context) => const Home()));
                  return Home();
                } else {
                  // Navigator.pushReplacement(
                  //     context,
                  //     MaterialPageRoute(
                  //         builder: (BuildContext context) => const Login()));
                  return Login();
                }
            }
          }),
    );
  }
}

