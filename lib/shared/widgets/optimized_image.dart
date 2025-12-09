import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/app_theme.dart';
import 'loading_widgets.dart';

/// Widget d'image optimisé pour connexions faibles avec placeholders et gestion d'erreurs
class OptimizedNetworkImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? errorWidget;
  final Color? backgroundColor;

  const OptimizedNetworkImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.errorWidget,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.circular(AppTheme.radiusLarge),
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        width: width,
        height: height,
        fit: fit,
        
        // Affichage progressif pour connexions lentes
        progressIndicatorBuilder: (context, url, downloadProgress) {
          return Container(
            width: width,
            height: height,
            color: backgroundColor ?? AppTheme.lightGray,
            child: Stack(
              children: [
                // Skeleton avec shimmer
                ImageSkeleton(
                  width: width ?? double.infinity,
                  height: height ?? double.infinity,
                  borderRadius: BorderRadius.zero,
                ),
                // Indicateur de progression
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 40,
                        height: 40,
                        child: CircularProgressIndicator(
                          value: downloadProgress.progress,
                          strokeWidth: 3,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            AppTheme.caribbeanTurquoise,
                          ),
                          backgroundColor: AppTheme.mediumGray,
                        ),
                      ),
                      if (downloadProgress.progress != null) ...[
                        const SizedBox(height: AppTheme.spacing8),
                        Text(
                          '${(downloadProgress.progress! * 100).toInt()}%',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.darkGray,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          );
        },
        
        // Widget d'erreur personnalisé
        errorWidget: (context, url, error) {
          return errorWidget ??
              Container(
                width: width,
                height: height,
                color: backgroundColor ?? AppTheme.lightGray,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppTheme.spacing16),
                      decoration: BoxDecoration(
                        color: AppTheme.mediumGray,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.broken_image_outlined,
                        size: 40,
                        color: AppTheme.darkGray,
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacing8),
                    const Text(
                      'Image non disponible',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.darkGray,
                      ),
                    ),
                  ],
                ),
              );
        },
        
        // Configuration du cache
        memCacheWidth: width != null ? (width! * 2).toInt() : null,
        memCacheHeight: height != null ? (height! * 2).toInt() : null,
        maxWidthDiskCache: 800,
        maxHeightDiskCache: 800,
      ),
    );
  }
}

/// Widget pour Hero d'image avec transition fluide
class HeroOptimizedImage extends StatelessWidget {
  final String imageUrl;
  final String heroTag;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  const HeroOptimizedImage({
    super.key,
    required this.imageUrl,
    required this.heroTag,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: heroTag,
      child: OptimizedNetworkImage(
        imageUrl: imageUrl,
        width: width,
        height: height,
        fit: fit,
        borderRadius: borderRadius,
      ),
    );
  }
}

/// Carousel d'images optimisé
class OptimizedImageCarousel extends StatefulWidget {
  final List<String> imageUrls;
  final double height;
  final bool autoPlay;
  final Duration autoPlayInterval;

  const OptimizedImageCarousel({
    super.key,
    required this.imageUrls,
    this.height = 250,
    this.autoPlay = false,
    this.autoPlayInterval = const Duration(seconds: 5),
  });

  @override
  State<OptimizedImageCarousel> createState() => _OptimizedImageCarouselState();
}

class _OptimizedImageCarouselState extends State<OptimizedImageCarousel> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.imageUrls.isEmpty) {
      return Container(
        height: widget.height,
        color: AppTheme.lightGray,
        child: const Center(
          child: Icon(
            Icons.image_not_supported,
            size: 64,
            color: AppTheme.darkGray,
          ),
        ),
      );
    }

    return Stack(
      children: [
        // PageView d'images
        SizedBox(
          height: widget.height,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: widget.imageUrls.length,
            itemBuilder: (context, index) {
              return OptimizedNetworkImage(
                imageUrl: widget.imageUrls[index],
                width: double.infinity,
                height: widget.height,
                fit: BoxFit.cover,
                borderRadius: BorderRadius.zero,
              );
            },
          ),
        ),
        
        // Gradient overlay en bas
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.6),
                ],
              ),
            ),
          ),
        ),
        
        // Indicateurs de page
        if (widget.imageUrls.length > 1)
          Positioned(
            bottom: AppTheme.spacing16,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                widget.imageUrls.length,
                (index) => AnimatedContainer(
                  duration: AppTheme.animationFast,
                  margin: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacing4,
                  ),
                  width: _currentPage == index ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? AppTheme.white
                        : AppTheme.white.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                  ),
                ),
              ),
            ),
          ),
        
        // Boutons de navigation
        if (widget.imageUrls.length > 1) ...[
          // Bouton précédent
          if (_currentPage > 0)
            Positioned(
              left: AppTheme.spacing8,
              top: 0,
              bottom: 0,
              child: Center(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: () {
                      _pageController.previousPage(
                        duration: AppTheme.animationNormal,
                        curve: Curves.easeInOut,
                      );
                    },
                  ),
                ),
              ),
            ),
          // Bouton suivant
          if (_currentPage < widget.imageUrls.length - 1)
            Positioned(
              right: AppTheme.spacing8,
              top: 0,
              bottom: 0,
              child: Center(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: () {
                      _pageController.nextPage(
                        duration: AppTheme.animationNormal,
                        curve: Curves.easeInOut,
                      );
                    },
                  ),
                ),
              ),
            ),
        ],
      ],
    );
  }
}

/// Grid d'images optimisé
class OptimizedImageGrid extends StatelessWidget {
  final List<String> imageUrls;
  final int crossAxisCount;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final double childAspectRatio;

  const OptimizedImageGrid({
    super.key,
    required this.imageUrls,
    this.crossAxisCount = 2,
    this.mainAxisSpacing = AppTheme.spacing8,
    this.crossAxisSpacing = AppTheme.spacing8,
    this.childAspectRatio = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: mainAxisSpacing,
        crossAxisSpacing: crossAxisSpacing,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: imageUrls.length,
      itemBuilder: (context, index) {
        return OptimizedNetworkImage(
          imageUrl: imageUrls[index],
          fit: BoxFit.cover,
        );
      },
    );
  }
}
