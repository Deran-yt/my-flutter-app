import 'package:flutter/material.dart';
import 'home_page.dart';
import 'upload_page.dart';
import 'profile_page.dart';
import 'user_repository.dart';

class Dashboard extends StatefulWidget {
  final String userName;
  final String userEmail;

  const Dashboard({super.key, required this.userName, required this.userEmail});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int _selectedIndex = 0;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const HomePage(),
      const UploadPage(),
      ProfilePage(userName: widget.userName, userEmail: widget.userEmail),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: UserRepository.instance,
      builder: (context, _) {
        final userName = UserRepository.instance.userName.isNotEmpty
            ? UserRepository.instance.userName
            : widget.userName;
        final userEmail = UserRepository.instance.userEmail.isNotEmpty
            ? UserRepository.instance.userEmail
            : widget.userEmail;

        return Scaffold(
          appBar: AppBar(
            title: Text('Welcome, ${userName.split(' ').first}'),
            backgroundColor: const Color(0xFF3F51B5),
          ),
          drawer: Drawer(
            child: SafeArea(
              child: Column(
                children: [
                  UserAccountsDrawerHeader(
                    accountName: Text(userName),
                    accountEmail: Text(userEmail),
                    currentAccountPicture: CircleAvatar(
                      backgroundColor: Colors.purple.shade200,
                      child: Text(userName.isNotEmpty ? userName[0].toUpperCase() : 'U'),
                    ),
                    decoration: const BoxDecoration(color: Color(0xFF3F51B5)),
                  ),
                  ListTile(
                    leading: const Icon(Icons.person),
                    title: const Text('Profile'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => ProfilePage(userName: userName, userEmail: userEmail)),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.upload_file),
                    title: const Text('Upload'),
                    onTap: () {
                      Navigator.pop(context);
                      setState(() => _selectedIndex = 1);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.settings),
                    title: const Text('Settings'),
                    onTap: () => ScaffoldMessenger.of(context)
                        .showSnackBar(const SnackBar(content: Text('Settings coming soon'))),
                  ),
                  ListTile(
                    leading: UserRepository.instance.darkMode ? const Icon(Icons.light_mode) : const Icon(Icons.dark_mode),
                    title: Text(UserRepository.instance.darkMode ? 'Light Mode' : 'Dark Mode'),
                    onTap: () => UserRepository.instance.toggleDarkMode(),
                  ),
                  const Spacer(),
                  ListTile(
                    leading: const Icon(Icons.logout),
                    title: const Text('Logout'),
                    onTap: () {
                      UserRepository.instance.clear();
                      Navigator.popUntil(context, (r) => r.isFirst);
                    },
                  ),
                ],
              ),
            ),
          ),
          body: _pages[_selectedIndex],
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _selectedIndex,
            selectedItemColor: const Color(0xFF3F51B5),
            onTap: _onItemTapped,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
              BottomNavigationBarItem(icon: Icon(Icons.upload_file), label: "Upload"),
              BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: const Color(0xFF3F51B5),
            onPressed: () => ScaffoldMessenger.of(context)
                .showSnackBar(const SnackBar(content: Text('Quick action pressed'))),
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }
}
