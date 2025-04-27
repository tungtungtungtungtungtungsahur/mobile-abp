import 'package:flutter/material.dart';
import '../cart_service.dart';

class CustomBottomNavigationBar extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const CustomBottomNavigationBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  State<CustomBottomNavigationBar> createState() => _CustomBottomNavigationBarState();
}

class _CustomBottomNavigationBarState extends State<CustomBottomNavigationBar> {
  int _cartCount = 0;

  @override
  void initState() {
    super.initState();
    _subscribeToCartCount();
  }

  void _subscribeToCartCount() {
    CartService.getCartItems().listen((items) {
      setState(() {
        _cartCount = items.length;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: <BottomNavigationBarItem>[
        const BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Beranda',
        ),
        BottomNavigationBarItem(
          icon: _buildIconWithBadge(Icons.chat_bubble_outline, 3),
          activeIcon: _buildIconWithBadge(Icons.chat_bubble_outline, 3),
          label: 'Pesan',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.attach_money_outlined),
          activeIcon: Icon(Icons.attach_money),
          label: 'Jual',
        ),
        BottomNavigationBarItem(
          icon: _buildIconWithBadge(Icons.shopping_cart_outlined, _cartCount),
          activeIcon: _buildIconWithBadge(Icons.shopping_cart, _cartCount),
          label: 'Keranjang',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: 'Akun',
        ),
      ],
      currentIndex: widget.selectedIndex,
      selectedItemColor: Colors.deepOrange,
      unselectedItemColor: Colors.grey[600],
      onTap: widget.onItemTapped,
      type: BottomNavigationBarType.fixed,
      showUnselectedLabels: true,
      backgroundColor: Colors.white,
      elevation: 5.0,
    );
  }

  Widget _buildIconWithBadge(IconData icon, int count) {
    if (count <= 0) {
      return Icon(icon);
    }
    return Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        Icon(icon),
        Positioned(
          right: -5,
          top: -5,
          child: Container(
            padding: const EdgeInsets.all(1),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(8),
            ),
            constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
            child: Text(
              '$count',
              style: const TextStyle(color: Colors.white, fontSize: 10),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }
}
