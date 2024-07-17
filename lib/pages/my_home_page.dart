import 'package:comt/pages/todo_page.dart';
import 'package:flutter/material.dart';


class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 1;
  final PageController _pageController = PageController(initialPage: 1);

  final List<Widget> _pages = <Widget>[
    todoPage(),

    todoPage(),

    todoPage(),
    // HomePage(),

    // PicksPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.animateToPage(index,
        duration: Duration(milliseconds: 250), curve: Curves.easeInOut);
  }

  // Future<void> _logout() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   await prefs.remove('jwt_token');
  //   Navigator.of(context).pushReplacement(
  //     MaterialPageRoute(builder: (context) => LoginPage()),
  //   );
  // }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset('assets/img/COMT-clock.png', height: 50,),
        centerTitle: true,
        backgroundColor: Colors.white,
        // actions: [
        //   IconButton(
        //     icon: Icon(Icons.logout, color: Color(0xFFFFA423)),
        //     onPressed: _logout,
        //   ),
        // ],
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.playlist_add_check),
            label: 'TODO',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'HOME',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.pie_chart),
            label: 'ANALYSIS',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Color(0xFF4BA933),
        onTap: _onItemTapped,
        backgroundColor: Colors.white,
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: TextStyle(color: Color(0xFF4BA933)),
        unselectedLabelStyle: TextStyle(color: Colors.grey),
      ),
      backgroundColor: Colors.white,
    );
  }
}
