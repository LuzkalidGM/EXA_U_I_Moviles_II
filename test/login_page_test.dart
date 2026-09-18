import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gameon/features/perfil/models/usuario_deportista.dart';
import 'package:gameon/features/perfil/viewmodels/perfil_viewmodel.dart';
import 'package:gameon/features/perfil/views/login_page/login_page.dart';
import 'package:gameon/features/perfil/views/login_page/widgets/custom_button.dart';
import 'package:gameon/features/perfil/views/perfil_view/perfil_view.dart';
import 'package:gameon/features/perfil/views/perfil_view/unauthenticated/forms/login_form.dart';
import 'package:provider/provider.dart';

class _LoginViewModel extends ChangeNotifier implements PerfilViewModel {
  String? submittedEmail;
  String? submittedPassword;
  int loginCalls = 0;
  LoginResult result = LoginResult.error('Correo o contraseña incorrectos');

  @override
  bool get isLoggingIn => false;

  @override
  bool get isSigningUp => false;

  @override
  UsuarioDeportista? get profile => null;

  @override
  Future<LoginResult> login({
    required String email,
    required String password,
  }) async {
    loginCalls++;
    submittedEmail = email;
    submittedPassword = password;
    return result;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<void> _openLogin(WidgetTester tester, _LoginViewModel vm) async {
  tester.view.physicalSize = const Size(900, 1400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    ChangeNotifierProvider<PerfilViewModel>.value(
      value: vm,
      child: MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: ElevatedButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const LoginPage()),
              ),
              child: const Text('Abrir login'),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Abrir login'));
  await tester.pumpAndSettle();
}

Finder get _loginButton => find.widgetWithText(CustomButton, 'Iniciar Sesión');

void main() {
  testWidgets('El perfil permite abrir el login en una pantalla pequeña', (
    tester,
  ) async {
    final vm = _LoginViewModel();
    addTearDown(vm.dispose);
    tester.view.physicalSize = const Size(330, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      ChangeNotifierProvider<PerfilViewModel>.value(
        value: vm,
        child: const MaterialApp(home: PerfilView()),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Registrarme / Iniciar sesión'));
    await tester.pumpAndSettle();
    expect(find.byType(LoginForm), findsOneWidget);
    expect(tester.takeException(), isNull);
    expect(vm.loginCalls, 0);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });

  testWidgets('No autentica cuando los campos están vacíos', (tester) async {
    final vm = _LoginViewModel();
    addTearDown(vm.dispose);
    await _openLogin(tester, vm);
    await tester.tap(_loginButton);
    await tester.pumpAndSettle();
    expect(find.text('Ingresa tu correo'), findsOneWidget);
    expect(find.text('Ingresa tu contraseña'), findsOneWidget);
    expect(vm.loginCalls, 0);
  });

  testWidgets('Usa la sesión compartida y conserva la contraseña exacta', (
    tester,
  ) async {
    final vm = _LoginViewModel();
    addTearDown(vm.dispose);
    await _openLogin(tester, vm);
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), ' deportista@example.com ');
    await tester.enterText(fields.at(1), ' clave con espacios ');
    await tester.tap(_loginButton);
    await tester.pumpAndSettle();
    expect(vm.submittedEmail, 'deportista@example.com');
    expect(vm.submittedPassword, ' clave con espacios ');
    expect(find.text('Correo o contraseña incorrectos'), findsOneWidget);
    expect(find.byType(LoginPage), findsOneWidget);
  });

  testWidgets('Vuelve a la pantalla anterior después de un login correcto', (
    tester,
  ) async {
    final vm = _LoginViewModel()..result = LoginResult.success();
    addTearDown(vm.dispose);
    await _openLogin(tester, vm);
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'deportista@example.com');
    await tester.enterText(fields.at(1), 'clave123');
    await tester.tap(_loginButton);
    await tester.pumpAndSettle();
    expect(vm.loginCalls, 1);
    expect(find.byType(LoginPage), findsNothing);
    expect(find.text('Abrir login'), findsOneWidget);
  });
}
