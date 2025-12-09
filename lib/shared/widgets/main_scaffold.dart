import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../core/theme/app_theme.dart';

class MainScaffold extends StatefulWidget {
  final Widget child;

  const MainScaffold({
    super.key,
    required this.child,
  });

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: AppTheme.animationFast,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateCurrentIndex();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Synchroniser l'index avec la route actuelle
  void _updateCurrentIndex() {
    final location = GoRouterState.of(context).uri.path;
    int newIndex = 0;
    
    if (location == '/') {
      newIndex = 0;
    } else if (location == '/establishments') {
      newIndex = 1;
    } else if (location == '/sites') {
      newIndex = 2;
    } else if (location == '/favorites') {
      newIndex = 3;
    } else if (location == '/profile') {
      newIndex = 4;
    }
    
    if (_currentIndex != newIndex) {
      setState(() {
        _currentIndex = newIndex;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppTheme.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacing8,
              vertical: AppTheme.spacing8,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  index: 0,
                  icon: Icons.home_rounded,
                  activeIcon: Icons.home,
                  label: 'navigation.home'.tr(),
                  color: AppTheme.caribbeanTurquoise,
                ),
                _buildNavItem(
                  index: 1,
                  icon: Icons.store_rounded,
                  activeIcon: Icons.store,
                  label: 'navigation.establishments'.tr(),
                  color: AppTheme.coralSunset,
                ),
                _buildNavItem(
                  index: 2,
                  icon: Icons.place_rounded,
                  activeIcon: Icons.place,
                  label: 'navigation.sites'.tr(),
                  color: AppTheme.tropicalGreen,
                ),
                _buildNavItem(
                  index: 3,
                  icon: Icons.favorite_rounded,
                  activeIcon: Icons.favorite,
                  label: 'navigation.favorites'.tr(),
                  color: AppTheme.hibiscusRed,
                ),
                _buildNavItem(
                  index: 4,
                  icon: Icons.person_rounded,
                  activeIcon: Icons.person,
                  label: 'navigation.profile'.tr(),
                  color: AppTheme.oceanBlue,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required Color color,
  }) {
    final isSelected = _currentIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => _onTap(index),
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: AppTheme.spacing8,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon avec animation
              AnimatedContainer(
                duration: AppTheme.animationFast,
                curve: Curves.easeInOut,
                padding: EdgeInsets.all(isSelected ? AppTheme.spacing8 : 0),
                decoration: BoxDecoration(
                  color: isSelected
                      ? color.withOpacity(0.15)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                ),
                child: Icon(
                  isSelected ? activeIcon : icon,
                  color: isSelected ? color : AppTheme.darkGray,
                  size: isSelected ? 28 : 24,
                ),
              ),
              const SizedBox(height: AppTheme.spacing4),
              // Label
              AnimatedDefaultTextStyle(
                duration: AppTheme.animationFast,
                style: TextStyle(
                  fontSize: isSelected ? 12 : 11,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected ? color : AppTheme.darkGray,
                  letterSpacing: 0.5,
                ),
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
              // Indicateur actif
              const SizedBox(height: AppTheme.spacing4),
              AnimatedContainer(
                duration: AppTheme.animationFast,
                height: 3,
                width: isSelected ? 20 : 0,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onTap(int index) {
    if (_currentIndex == index) return;

    setState(() {
      _currentIndex = index;
    });

    _animationController.forward(from: 0);

    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.go('/establishments');
        break;
      case 2:
        context.go('/sites');
        break;
      case 3:
        context.go('/favorites');
        break;
      case 4:
        context.go('/profile');
        break;
    }
  }
}
