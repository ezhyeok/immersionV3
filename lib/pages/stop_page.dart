import 'dart:math';

import 'package:comt/pages/todo_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../widgets/font.dart';

class animation extends StatefulWidget {
  @override
  _animationState createState() => _animationState();
}

class _animationState extends State<animation> {
  int _currentAnimation = 0;

  void _onAnimationComplete() {
    setState(() {
      _currentAnimation++;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget currentAnimation;
    switch (_currentAnimation) {
      case 0:
        currentAnimation = circle_clockwise(onComplete: _onAnimationComplete);
        break;
      case 1:
        currentAnimation = circle_fadeOut(onComplete: _onAnimationComplete);
        break;
      case 2:
        currentAnimation = blink(onComplete: _onAnimationComplete);
        break;
      case 3:
        currentAnimation = blink_fadeOut(onComplete: _onAnimationComplete);
        break;
      case 4:
        currentAnimation = breath_fadeIn(onComplete: _onAnimationComplete);
        break;
      case 5:
        currentAnimation = breath(onComplete: _onAnimationComplete);
        break;
      case 6:
        currentAnimation = breath_fadeOut(onComplete: _onAnimationComplete);
        break;
      default:
        currentAnimation = Container(); // 모든 애니메이션이 끝난 후 빈 컨테이너 표시
        Future.delayed(Duration(milliseconds: 100), () {
          Navigator.pop(context);
          // Navigator.push(
          //   context, MaterialPageRoute(builder: (context) => todoPage()),
          // );
        });
    // _pageController.animateToPage(0, duration: Duration(milliseconds: 250), curve: Curves.easeInOut);
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(child: Container(child: currentAnimation,),),
    );
  }
}

//////////////////////////////////////////// circle_clockwise 시작
class circle_clockwise extends StatefulWidget {
  final VoidCallback onComplete;

  const circle_clockwise({super.key, required this.onComplete});

  @override
  State<circle_clockwise> createState() => _circle_clockwiseState();
}

class _circle_clockwiseState extends State<circle_clockwise>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  int highlightIndex = 0;
  List<Animation<Color?>> _animations = [];
  int _completedCycles = 0;
  bool ccw = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 10),
    );

    _animations = List.generate(12, (index) {
      final start = index / 12;
      final end = (index + 1) / 12;
      return TweenSequence<Color?>([
        TweenSequenceItem(
          tween: ColorTween(begin: Color(0xFF5E5E5E), end: Color(0xFFFFFFFF)),
          weight: 50,
        ),
        TweenSequenceItem(
          tween: ColorTween(begin: Color(0xFFFFFFFF
          ), end: Color(0xFF5E5E5E)),
          weight: 50,
        ),
      ]).animate(CurvedAnimation(
        parent: _controller,
        curve: Interval(start, end, curve: Curves.linear),
      ));
    });

    _controller.forward();

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _completedCycles++;
        if (_completedCycles < 4) {
          if (_completedCycles == 2) ccw = false;
          _controller.reset();
          _controller.forward();
        } else {
          widget.onComplete();
        }
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const double _textSize = 150;
    List<Widget> printing = [];
    // printing.add(
    //   Transform.translate(
    //     offset: Offset(0, 0),
    //     child: Container(
    //       alignment: Alignment.center,
    //       child: Container(
    //         color: Colors.white,
    //       ),
    //     ),
    //   ),
    // );
    printing.add(
      Transform.translate(
        offset: Offset(0, 0),
        child: Center(child: Container(
          alignment: Alignment.center,
          width: _textSize,
          height: _textSize,
          child: Wrap(
            children: [
              Font('눈을 천천히\n굴리세요', 'XL', clr: Color(0xFFFFFFFF), bold: true)
            ],
          ),
        ),),
      ),
    );
    printing.addAll(
      List.generate(12, (index) {
        final double angle = (index * 2 * pi) / 12;
        const double r = 150;
        return AnimatedBuilder(
          animation: _animations[index],
          builder: (context, child) {
            return Transform.translate(
              offset: ccw
                  ? Offset(-r * sin(angle), -r * cos(angle))
                  : Offset(r * sin(angle), -r * cos(angle)),
              child: Center(child: Circle(_animations[index].value ?? Color(0xFF5E5E5E))),
            );
          },
        );
      }),
    );
    return Container(
      alignment: Alignment.center,
      child: Stack(
        children: printing,
      ),
    );
  }
}
//////////////////////////////////////////// circle_clockwise 끝

//////////////////////////////////////////// circle_fadeOut 시작
class circle_fadeOut extends StatefulWidget {
  final VoidCallback onComplete;

  const circle_fadeOut({super.key, required this.onComplete});

  @override
  State<circle_fadeOut> createState() => _circle_fadeOutState();
}

class _circle_fadeOutState extends State<circle_fadeOut>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  int highlightIndex = 0;
  List<Animation<double>> _animations = [];
  bool ccw = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    );

    _animations = List.generate(13, (index) {
      return Tween<double>(
        begin: 1.0,
        end: 0.0,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Interval(0, 1, curve: Curves.easeInOut),
      ));
    });

    _controller.forward();

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const double _textSize = 150;
    List<Widget> printing = [];
    // printing.add(
    //   AnimatedBuilder(
    //     animation: _animations[0],
    //     builder: (context, child) {
    //       return Transform.translate(
    //         offset: Offset(0, 0),
    //         child: Opacity(
    //           opacity: _animations[0].value,
    //           child: Container(
    //             color: Colors.white,
    //           ),
    //         ),
    //       );
    //     },
    //   ),
    // );
    printing.add(
      AnimatedBuilder(
        animation: _animations[0],
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, 0),
            child: Opacity(
              opacity: _animations[0].value,
              child: Center(child: Container(
                alignment: Alignment.center,
                width: _textSize,
                height: _textSize,
                child: Wrap(
                  children: [Font('눈을 천천히\n굴리세요', 'XL', clr: Color(0xFFFFFFFF), bold: true)],
                ),
              ),),
            ),
          );
        },
      ),
    );
    printing.addAll(
      List.generate(12, (index) {
        final double angle = (index * 2 * pi) / 12;
        const double r = 150;
        return AnimatedBuilder(
          animation: _animations[0],
          builder: (context, child) {
            return Transform.translate(
              offset: ccw ? Offset(-r * sin(angle), -r * cos(angle)) : Offset(r * sin(angle), -r * cos(angle)),
              child: Opacity(
                opacity: _animations[0].value,
                child: Center(child: Circle(Color(0xFF5E5E5E))),
              ),
            );
          },
        );
      }),
    );
    return Container(
      alignment: Alignment.center,
      child: Stack(
        children: printing,
      ),
    );
  }
}
//////////////////////////////////////////// circle_fadeOut 끝

//////////////////////////////////////////// blink 시작
class blink extends StatefulWidget {
  final VoidCallback onComplete;

  const blink({super.key, required this.onComplete});

  @override
  State<blink> createState() => _blinkState();
}

class _blinkState extends State<blink>
    with TickerProviderStateMixin {
  late final AnimationController _bgController, _textController;
  late Animation<double> _bgAnimations, _textAnimations;

  @override
  void initState() {
    super.initState();

    _bgController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 10),
    );
    _bgAnimations = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _bgController,
      curve: Interval(0, 1, curve: Curves.easeInOut),
    ));
    _bgController.forward();

    _textController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    )..repeat(reverse: true);
    _textAnimations = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Interval(0, 1, curve: Curves.easeInOut),
    ));

    _bgController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete();
      }
    });
  }

  @override
  void dispose() {
    _bgController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> printing = [];
    printing.add(
      FadeTransition(
        opacity: _bgAnimations,
        child: Container(
          color: Colors.white,
        ),
      ),
    );
    printing.add(
      FadeTransition(
        opacity: _textAnimations,
        child: Center(
          child: Font('눈을 빠르게\n깜박이세요', 'XL', clr: Color(0xFF4BA933), bold: true),
        ),
      ),
    );
    return Container(
      alignment: Alignment.center,
      child: Stack(
        children: printing,
      ),
    );
  }

}
//////////////////////////////////////////// blink 끝

//////////////////////////////////////////// blink_fadeOut 시작
class blink_fadeOut extends StatefulWidget {
  final VoidCallback onComplete;

  const blink_fadeOut({super.key, required this.onComplete});

  @override
  State<blink_fadeOut> createState() => _blink_fadeOutState();
}

class _blink_fadeOutState extends State<blink_fadeOut>
    with TickerProviderStateMixin {
  late final AnimationController _bgController;
  late Animation<double> _bgAnimations;

  @override
  void initState() {
    super.initState();

    _bgController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    );
    _bgAnimations = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _bgController,
      curve: Interval(0, 1, curve: Curves.easeInOut),
    ));
    _bgController.forward();
    _bgController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete();
      }
    });
  }

  @override
  void dispose() {
    _bgController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> printing = [];
    printing.add(
      FadeTransition(
        opacity: _bgAnimations,
        child: Container(
          color: Colors.white,
        ),
      ),
    );
    return Container(
      alignment: Alignment.center,
      child: Stack(
        children: printing,
      ),
    );
  }

}
//////////////////////////////////////////// blink_fadeOut 끝

//////////////////////////////////////////// breath_fadeIn 시작
class breath_fadeIn extends StatefulWidget {
  final VoidCallback onComplete;

  const breath_fadeIn({super.key, required this.onComplete});

  @override
  State<breath_fadeIn> createState() => _breath_fadeInState();
}

class _breath_fadeInState extends State<breath_fadeIn>
    with TickerProviderStateMixin {
  late final AnimationController _circleController;
  late Animation<double> _circleAnimations;

  @override
  void initState() {
    super.initState();

    _circleController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _circleAnimations = Tween<double>(
      begin: 0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _circleController,
      curve: Curves.easeInOut,
    ));
    _circleController.forward();
    _circleController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete();
      }
    });
  }

  @override
  void dispose() {
    _circleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> printing = [];
    printing.add(
        Center(
          child: ScaleTransition(
            scale: _circleAnimations,
            child: Circle(Color(0xFF4BA933), size: 200,),
          ),
        )
    );
    return Container(
      alignment: Alignment.center,
      child: Stack(
        children: printing,
      ),
    );
  }
}
//////////////////////////////////////////// breath_fadeIn 끝

//////////////////////////////////////////// breath 시작
class breath extends StatefulWidget {
  final VoidCallback onComplete;

  const breath({super.key, required this.onComplete});

  @override
  State<breath> createState() => _breathState();
}

class _breathState extends State<breath>
    with TickerProviderStateMixin {
  late final AnimationController _circleController, _textController;
  late Animation<double> _circleAnimations, _textAnimations;
  int _textIndex = 0;
  int cnt = 0;

  @override
  void initState() {
    super.initState();

    _circleController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);
    _circleAnimations = Tween<double>(
      begin: 1,
      end: 1.5,
    ).animate(CurvedAnimation(
      parent: _circleController,
      curve: Curves.easeInOut,
    ));

    _textController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    )..repeat(reverse: true);
    _textAnimations = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_textController)
      ..addListener(() {
        setState(() {});
      })
      ..addStatusListener((status) {
        if (status != AnimationStatus.reverse) {
          setState(() {
            _textIndex = 1 - _textIndex;
            cnt++;
            if (cnt == 4) widget.onComplete();
          });
        }
      });
  }

  @override
  void dispose() {
    _circleController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> printing = [];
    printing.add(
        Center(
          child: ScaleTransition(
            scale: _circleAnimations,
            child: Circle(Color(0xFF4BA933), size: 200,),
          ),
        )
    );
    printing.add(
      FadeTransition(
        opacity: _textAnimations,
        child: Center(
          child: Font(_textIndex == 0 ? '숨을 들이쉬고' : '내쉬세요', 'XL', clr: Color(0xFFFFFFFF), bold: true),
        ),
      ),
    );
    return Container(
      alignment: Alignment.center,
      child: Stack(
        children: printing,
      ),
    );
  }
}
//////////////////////////////////////////// breath 끝

//////////////////////////////////////////// breath_fadeOut 시작
class breath_fadeOut extends StatefulWidget {
  final VoidCallback onComplete;

  const breath_fadeOut({super.key, required this.onComplete});

  @override
  State<breath_fadeOut> createState() => _breath_fadeOutState();
}

class _breath_fadeOutState extends State<breath_fadeOut>
    with TickerProviderStateMixin {
  late final AnimationController _circleController;
  late Animation<double> _circleAnimations;

  @override
  void initState() {
    super.initState();

    _circleController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _circleAnimations = Tween<double>(
      begin: 1.0,
      end: 0,
    ).animate(CurvedAnimation(
      parent: _circleController,
      curve: Curves.easeInOut,
    ));
    _circleController.forward();
    _circleController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete();
      }
    });
  }

  @override
  void dispose() {
    _circleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> printing = [];
    printing.add(
        Center(
          child: ScaleTransition(
            scale: _circleAnimations,
            child: Circle(Color(0xFF4BA933), size: 200,),
          ),
        )
    );
    return Container(
      alignment: Alignment.center,
      child: Stack(
        children: printing,
      ),
    );
  }
}
//////////////////////////////////////////// breath_fadeOut 끝

class Circle extends StatelessWidget {
  final Color clr;
  final double size;
  Circle(this.clr, {this.size = 20});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: clr,
      ),
    );
  }
}