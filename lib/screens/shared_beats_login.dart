import "package:flutter/material.dart";

import "../services/shared_beats_api.dart";

class SharedBeatsLogin extends StatefulWidget {
  final VoidCallback? onSignedIn;
  const SharedBeatsLogin({super.key, this.onSignedIn});
  @override
  State<SharedBeatsLogin> createState() => _SharedBeatsLoginState();
}

class _SharedBeatsLoginState extends State<SharedBeatsLogin> {
  final username = TextEditingController();
  final password = TextEditingController();
  bool loading = false;
  bool obscure = true;
  String? error;

  @override
  void dispose() {
    username.dispose();
    password.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    if (username.text.trim().isEmpty || password.text.isEmpty) {
      setState(() => error = "Enter your username and password.");
      return;
    }
    setState(() {
      loading = true;
      error = null;
    });
    try {
      await SharedBeatsApi.login(username.text.trim(), password.text);
      if (mounted) {
        if (widget.onSignedIn != null) {
          widget.onSignedIn!();
        } else {
          Navigator.of(context).pop(true);
        }
      }
    } catch (e) {
      if (mounted) setState(() => error = e.toString());
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const gold = Color(0xFFD9AE58);
    const cyan = Color(0xFF56DDF4);
    return Scaffold(
      backgroundColor: const Color(0xFF060D20),
      appBar: AppBar(
        title: const Text("999 COMMON BEATS"),
        backgroundColor: const Color(0xFF0A1530),
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF050A19), Color(0xFF102C53), Color(0xFF071021)],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: const Color(0xE6101C37),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: gold, width: 1.5),
                  boxShadow: const [
                    BoxShadow(color: Color(0x5536BDEB), blurRadius: 36),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      "assets/images/common_web_logo.png",
                      height: 116,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "COMMON WEB",
                      style: TextStyle(
                        fontSize: 29,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 3,
                        color: gold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "Sign in to your Common Web account",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 28),
                    TextField(
                      controller: username,
                      enabled: !loading,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.username],
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: "Username or Email",
                        labelStyle: const TextStyle(color: cyan),
                        prefixIcon: const Icon(
                          Icons.person_outline,
                          color: cyan,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: cyan),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: gold, width: 2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: password,
                      enabled: !loading,
                      obscureText: obscure,
                      onSubmitted: (_) => submit(),
                      autofillHints: const [AutofillHints.password],
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: "Password",
                        labelStyle: const TextStyle(color: cyan),
                        prefixIcon: const Icon(Icons.lock_outline, color: cyan),
                        suffixIcon: IconButton(
                          onPressed: () => setState(() => obscure = !obscure),
                          icon: Icon(
                            obscure ? Icons.visibility : Icons.visibility_off,
                            color: cyan,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: cyan),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: gold, width: 2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    if (error != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        error!,
                        style: const TextStyle(color: Colors.redAccent),
                      ),
                    ],
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: loading ? null : submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: gold,
                          foregroundColor: const Color(0xFF101827),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          loading ? "Signing in..." : "Sign In",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    const Text(
                      "Protected by 999 Backend",
                      style: TextStyle(color: Colors.white60, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
