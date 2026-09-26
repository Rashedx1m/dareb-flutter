import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/data/mock_catalog.dart';

/// عارض صور الألبوم بملء الشاشة مع خلفية معتمة، تمرير بين الصور، وزر إغلاق.
class PhotoViewerPage extends StatefulWidget {
  const PhotoViewerPage({super.key, required this.albumId, required this.initialIndex});

  final String albumId;
  final int initialIndex;

  @override
  State<PhotoViewerPage> createState() => _PhotoViewerPageState();
}

class _PhotoViewerPageState extends State<PhotoViewerPage> {
  late final List<String> _photos;
  late final PageController _controller;
  late int _current;

  @override
  void initState() {
    super.initState();
    final albums = MockCatalog.galleryAlbums;
    final album = albums.firstWhere(
      (a) => a.id == widget.albumId,
      orElse: () => albums.first,
    );
    _photos = album.photos;
    final maxIndex = _photos.isEmpty ? 0 : _photos.length - 1;
    _current = widget.initialIndex.clamp(0, maxIndex);
    _controller = PageController(initialPage: _current);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: const Color(0xF20E1114),
        body: SafeArea(
          child: Stack(
            children: [
              if (_photos.isNotEmpty)
                PageView.builder(
                  controller: _controller,
                  itemCount: _photos.length,
                  onPageChanged: (i) => setState(() => _current = i),
                  itemBuilder: (context, i) => Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                      child: InteractiveViewer(
                        maxScale: 4,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: Image.asset(_photos[i], fit: BoxFit.contain),
                        ),
                      ),
                    ),
                  ),
                ),
              Positioned(
                top: 8,
                left: 8,
                child: _CircleButton(
                  icon: Icons.close_rounded,
                  onTap: () => context.pop(),
                ),
              ),
              if (_photos.length > 1)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 18,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.45),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Directionality(
                        textDirection: TextDirection.ltr,
                        child: Text(
                          '${_current + 1} / ${_photos.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Lato',
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.45),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 42,
          height: 42,
          child: Icon(icon, color: Colors.white, size: 24),
        ),
      ),
    );
  }
}
