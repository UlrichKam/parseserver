import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';
import 'package:parseserver/providers/auth_provider.dart';
import 'package:parseserver/screens/home.dart';
import 'package:provider/provider.dart';


class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _handleLogin(
      {required BuildContext context,
        required String userName,
        required String password}) async {
    final ParseUser user = ParseUser(userName, password, null);

    ParseResponse response = await user.login();

    if (response.success) {
      /// Login Successful
      print("*************************************************************");
      print("Login successful");

      ParseUser user = await ParseUser.currentUser() as ParseUser;
      context.read<Auth>().authenticate(user);
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => const Home()));
    } else {
      /// Login Failed
      print("*************************************************************");
      print("Login failed");
      print(response.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              children: [
                const Text(
                  "Login",
                  style: TextStyle(fontSize: 30),
                ),
                Text(
                  context.watch<Auth>().user?.username ?? "No user",
                ),
              ],
            ),
            TextFormField(
              controller: _userNameController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              obscureText: false,
              decoration: const InputDecoration(labelText: "User Name"),
            ),
            TextFormField(
              controller: _passwordController,
              keyboardType: TextInputType.visiblePassword,
              textInputAction: TextInputAction.next,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Password"),
            ),
            ElevatedButton(
              onPressed: () => _handleLogin(
                  context: context,
                  userName: _userNameController.text,
                  password: _passwordController.text),
              child: const Text("Login"),
            ),
          ],
        ),
      ),
    );
  }
}