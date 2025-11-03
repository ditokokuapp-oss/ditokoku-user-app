import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:carousel_slider/carousel_slider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';

class BannerView extends StatefulWidget {
  final bool isFeatured;
  const BannerView({super.key, required this.isFeatured});

  @override
  State<BannerView> createState() => _BannerViewState();
}

class _BannerViewState extends State<BannerView> {
  int _current = 0;
Future<List<Map<String, String>>>? _futureBanners;

  @override
  void initState() {
    super.initState();
    _futureBanners = fetchBanners();
  }

  Future<List<Map<String, String>>> fetchBanners() async {
    try {
      String apiUrl;

      if (widget.isFeatured) {
        apiUrl = 'https://apinew.ditokoku.id/api/banners/ditokoku/featured';
      } else {
        final splashController = Get.find<SplashController>();
        final int? moduleId = splashController.module?.id;

        if (moduleId != null && moduleId > 0) {
          apiUrl = 'https://apinew.ditokoku.id/api/banners/ditokoku/module/$moduleId';
        } else {
          apiUrl = 'https://apinew.ditokoku.id/api/banners/ditokoku/featured';
        }
      }

      final res = await http.get(Uri.parse(apiUrl));

      if (res.statusCode == 200) {
        final jsonData = json.decode(res.body);
        final List data = jsonData['data'] ?? [];

        // Jika kosong, fallback ke featured
        if (data.isEmpty && !widget.isFeatured) {
          return await _fetchFeaturedBanners();
        }

        return data.map<Map<String, String>>((b) {
          final img = b['image']?.toString() ?? '';
          final link = b['default_link']?.toString() ?? '';
          final isLaravelPattern = RegExp(
                  r'^\d{4}-\d{2}-\d{2}-[a-z0-9]+\.(png|jpg|jpeg|webp)$')
              .hasMatch(img);
          final imageUrl = isLaravelPattern
              ? 'https://dash.ditokoku.id/storage/app/public/banner/$img'
              : 'https://apinew.ditokoku.id/uploads/banners/$img';
          return {
            'image': imageUrl,
            'link': link,
          };
        }).toList();
      }
      return [];
    } catch (e) {
      print('💥 Exception: $e');
      return [];
    }
  }

  Future<List<Map<String, String>>> _fetchFeaturedBanners() async {
    try {
      const apiUrl = 'https://apinew.ditokoku.id/api/banners/ditokoku/featured';
      final res = await http.get(Uri.parse(apiUrl));

      if (res.statusCode == 200) {
        final jsonData = json.decode(res.body);
        final List data = jsonData['data'] ?? [];
        return data.map<Map<String, String>>((b) {
          final img = b['image']?.toString() ?? '';
          final link = b['default_link']?.toString() ?? '';
          final isLaravelPattern = RegExp(
                  r'^\d{4}-\d{2}-\d{2}-[a-z0-9]+\.(png|jpg|jpeg|webp)$')
              .hasMatch(img);
          final imageUrl = isLaravelPattern
              ? 'https://dash.ditokoku.id/storage/app/public/banner/$img'
              : 'https://apinew.ditokoku.id/uploads/banners/$img';
          return {
            'image': imageUrl,
            'link': link,
          };
        }).toList();
      }
      return [];
    } catch (e) {
      print('💥 Exception fetching featured: $e');
      return [];
    }
  }

  Future<void> _launchUrl(String url) async {
    if (url.isEmpty) return;
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      print('⚠️ Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, String>>>(
      future: _futureBanners,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
              child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: CircularProgressIndicator(
                      color: Theme.of(context).primaryColor)));
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }

        final banners = snapshot.data!;
        return Column(
          children: [
            CarouselSlider.builder(
              itemCount: banners.length,
              itemBuilder: (context, index, realIdx) {
                final banner = banners[index];
                final imageUrl = banner['image']!;
                final link = banner['link'] ?? '';

                return GestureDetector(
                  onTap: () => _launchUrl(link),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(Dimensions.radiusDefault),
                      boxShadow: const [
                        BoxShadow(
                            color: Colors.black26,
                            blurRadius: 6,
                            offset: Offset(0, 3))
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius:
                          BorderRadius.circular(Dimensions.radiusDefault),
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            color: Colors.grey[200],
                            child: Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes !=
                                        null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: Colors.grey[300],
                          child: const Center(
                            child: Icon(Icons.broken_image,
                                color: Colors.grey, size: 50),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
              options: CarouselOptions(
                autoPlay: true,
                enlargeCenterPage: false,
                disableCenter: true,
                viewportFraction: 1,
                autoPlayInterval: const Duration(seconds: 7),
                height: GetPlatform.isDesktop
                    ? 400
                    : MediaQuery.of(context).size.width / 2.5,
                onPageChanged: (index, reason) {
                  setState(() {
                    _current = index;
                  });
                },
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: banners.asMap().entries.map((entry) {
                return GestureDetector(
                  onTap: () => setState(() => _current = entry.key),
                  child: Container(
                    width: 8,
                    height: 8,
                    margin:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _current == entry.key
                          ? Theme.of(context).primaryColor
                          : Colors.grey.withOpacity(0.5),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        );
      },
    );
  }
}
