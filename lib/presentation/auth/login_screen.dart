import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/repositories/auth_repository.dart';
import '../../app/routes.dart';
import '../widgets/custom_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscurePass = true;
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeIn);
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthRepository>();
    final error = await auth.login(
      _emailCtrl.text.trim(),
      _passCtrl.text,
    );
    if (!mounted) return;
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
    // _AuthGate StreamBuilder handles navigation to home on auth state change
  }

  Future<void> _loginWithGoogle() async {
    final auth = context.read<AuthRepository>();
    final error = await auth.loginWithGoogle();
    if (!mounted) return;
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
    // _AuthGate StreamBuilder handles navigation to home on auth state change
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isLoading = context.watch<AuthRepository>().isLoading;

    return Scaffold(
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 48),
                _buildLogo(cs),
                const SizedBox(height: 40),
                _buildForm(isLoading),
                const SizedBox(height: 16),
                _buildDivider(),
                const SizedBox(height: 16),
                _buildGoogleButton(isLoading),
                const SizedBox(height: 24),
                _buildRegisterLink(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo(ColorScheme cs) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: cs.primaryContainer,
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.eco_rounded, size: 44, color: cs.primary),
        ),
        const SizedBox(height: 16),
        Text(
          'GreenWatch',
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                color: cs.primary,
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Cuida San Jerónimo juntos',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: cs.onSurface.withValues(alpha: 0.6),
              ),
        ),
      ],
    );
  }

  Widget _buildForm(bool isLoading) {
    final cs = Theme.of(context).colorScheme;
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _emailCtrl,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            style: TextStyle(color: cs.onSurface),
            decoration: const InputDecoration(
              labelText: 'Correo electrónico',
              prefixIcon: Icon(Icons.email_rounded),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Ingresa tu correo';
              if (!v.contains('@') || !v.contains('.')) return 'Correo no válido';
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _passCtrl,
            obscureText: _obscurePass,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _login(),
            style: TextStyle(color: cs.onSurface),
            decoration: InputDecoration(
              labelText: 'Contraseña',
              prefixIcon: const Icon(Icons.lock_rounded),
              suffixIcon: IconButton(
                icon: Icon(_obscurePass ? Icons.visibility_rounded : Icons.visibility_off_rounded),
                onPressed: () => setState(() => _obscurePass = !_obscurePass),
              ),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Ingresa tu contraseña';
              return null;
            },
          ),
          const SizedBox(height: 24),
          GreenButton(
            label: 'Ingresar',
            isLoading: isLoading,
            onPressed: _login,
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(child: Divider(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.5))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            '— o continúa con —',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                ),
          ),
        ),
        Expanded(child: Divider(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.5))),
      ],
    );
  }

  Widget _buildGoogleButton(bool isLoading) {
    return OutlinedButton.icon(
      onPressed: isLoading ? null : _loginWithGoogle,
      icon: const Icon(Icons.login_rounded, size: 20),
      label: const Text('Continuar con Google'),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 52),
      ),
    );
  }

  Widget _buildRegisterLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '¿No tienes cuenta? ',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, AppRoutes.register),
          child: Text(
            'Regístrate',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
      ],
    );
  }
}
