import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'bunny.dart';

class LottieDemo extends StatefulWidget {
  const LottieDemo({
    super.key,
  });

  @override
  State<LottieDemo> createState() => _LottieDemoState();
}

class _LottieDemoState extends State<LottieDemo> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Bunny _bunny;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    _controller.stop();
    _bunny = Bunny(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    /// يتم حساب عرض مربع الإدخال بطرح المساحة المتروكة 16 على اليسار واليمين من عرض الشاشة.
    final double textFieldWidth = MediaQuery.of(context).size.width - 32;

    return Scaffold(
      appBar: AppBar(
          centerTitle: true,
          systemOverlayStyle: SystemUiOverlayStyle.light,
          backgroundColor: Theme.of(context).colorScheme.primary,
          title: const Text(
            'Animation Login',
            style: TextStyle(color: Colors.white),
          ),
          iconTheme: IconThemeData(
            color: Theme.of(context).colorScheme.surface,
          )),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 32.0),
            Lottie.asset(
              'asset/animation/bunny_new_mouth.json',
              width: 275,
              height: 275,
              controller: _controller,
              fit: BoxFit.fill,
              onLoaded: (composition) {
                setState(() {
                  ///تعيين مدة الرسوم المتحركة
                  _controller.duration = composition.duration;
                });
              },
            ),
            const SizedBox(
              height: 30,
            ),
            MyTextField(
              prefix: Icons.email,
              labelText: 'Email',
              keyboardType: TextInputType.emailAddress,
              onHasFocus: (isObscure) {
                ///احصل على التركيز ، وابدأ حالة تتبع النص
                _bunny.setTrackingState();
              },
              onChanged: (text) {
                /// احسب نسبة عرض نص الإدخال إلى عرض مربع الإدخال
                _bunny.setEyesPosition(_getTextSize(text) / textFieldWidth);
              },
            ),
            MyTextField(
              prefix: Icons.lock,
              labelText: 'Password',
              keyboardType: TextInputType.visiblePassword,
              obscureText: true,
              onHasFocus: (isObscure) {
                /// احصل على التركيز ، حدد الحالة
                if (isObscure) {
                  _bunny.setShyState();
                } else {
                  _bunny.setPeekState();
                }
              },
              onObscureText: (isObscure) {
                if (isObscure) {
                  _bunny.setShyState();
                } else {
                  _bunny.setPeekState();
                }
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 15),
              child: SizedBox(
                height: 55,
                width: double.infinity,
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Theme.of(context).colorScheme.primaryContainer,
                        padding: const EdgeInsets.symmetric(horizontal: 40)),
                    onPressed: () {
                      _bunny.setTrackingState();
                    },
                    child: const Text(
                      'Login',
                      style: TextStyle(fontSize: 22),
                    )),
              ),
            )
          ],
        ),
      ),
    );
  }

  /// الحصول على عرض النص
  double _getTextSize(String text) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(
          text: text,
          style: const TextStyle(
            fontSize: 16.0,
          )),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout();
    return textPainter.size.width;
  }
}

class MyTextField extends StatefulWidget {
  const MyTextField(
      {super.key,
      required this.labelText,
      this.obscureText = false,
      this.keyboardType,
      this.onHasFocus,
      this.onObscureText,
      this.onChanged,
      this.prefix});

  final IconData? prefix;
  final String labelText;
  final bool obscureText;
  final TextInputType? keyboardType;

  /// احصل على التركيز المستمع
  final Function(bool isObscure)? onHasFocus;

  /// مراقبة كلمة المرور المرئية
  final Function(bool isObscure)? onObscureText;

  /// مراقبة إدخال النص
  final Function(String text)? onChanged;

  @override
  // ignore: library_private_types_in_public_api
  _MyTextFieldState createState() => _MyTextFieldState();
}

class _MyTextFieldState extends State<MyTextField> {
  bool _isObscure = true;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_refresh);
  }

  void _refresh() {
    if (_focusNode.hasFocus && widget.onHasFocus != null) {
      widget.onHasFocus?.call(_isObscure);
    }
    setState(() {});
  }

  @override
  void dispose() {
    _focusNode.removeListener(_refresh);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Listener(
        onPointerDown: (e) => FocusScope.of(context).requestFocus(_focusNode),
        child: TextFormField(
          focusNode: _focusNode,
          style: const TextStyle(color: Colors.black, fontSize: 18.0),
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            labelText: widget.labelText,
            labelStyle: const TextStyle(color: Colors.black, fontSize: 16),
            contentPadding: const EdgeInsets.all(18),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                width: 2,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.white, width: 2),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                width: 2,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            errorStyle: const TextStyle(fontSize: 12),
            prefixIcon: Icon(
              widget.prefix,
              color: Colors.black,
            ),
            suffixIcon: widget.obscureText
                ? IconButton(
                    icon: Icon(
                        _isObscure ? Icons.visibility_off : Icons.visibility,
                        color: Colors.black),
                    onPressed: () {
                      setState(() {
                        _isObscure = !_isObscure;
                      });
                      if (widget.onObscureText != null) {
                        widget.onObscureText?.call(_isObscure);
                      }
                    },
                  )
                : null,
          ),
          keyboardType: widget.keyboardType,
          obscureText: widget.obscureText ? _isObscure : widget.obscureText,
          onChanged: widget.onChanged,
        ),
      ),
    );
  }
}
