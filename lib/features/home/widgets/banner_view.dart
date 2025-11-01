import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:carousel_slider/carousel_slider.dart';
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
  Future<List<String>>? _futureBanners;

  @override
  void initState() {
    super.initState();
    _futureBanners = fetchBanners();
  }

  Future<List<String>> fetchBanners() async {
    try {
      String apiUrl;
      
      if (widget.isFeatured) {
        // ✅ isFeatured = true → ambil featured banner
        apiUrl = 'https://apinew.ditokoku.id/api/banners/ditokoku/featured';
        print('🌟 Fetching FEATURED banners');
      } else {
        // ✅ isFeatured = false → cek module_id
        final splashController = Get.find<SplashController>();
        final int? moduleId = splashController.module?.id;
        
        if (moduleId != null && moduleId > 0) {
          // Ada module_id → ambil banner sesuai module
          apiUrl = 'https://apinew.ditokoku.id/api/banners/ditokoku/module/$moduleId';
          print('🎯 Fetching banners for module_id: $moduleId');
        } else {
          // Tidak ada module_id → fallback ke featured
          apiUrl = 'https://apinew.ditokoku.id/api/banners/ditokoku/featured';
          print('🔄 No module_id, fallback to FEATURED banners');
        }
      }
      
      print('🌐 API URL: $apiUrl');
      
      final res = await http.get(Uri.parse(apiUrl));
      
      if (res.statusCode == 200) {
        final jsonData = json.decode(res.body);
        final List data = jsonData['data'] ?? [];

        print('📊 Found ${data.length} banners');

        // ✅ Jika tidak ada banner untuk module, fallback ke featured
        if (data.isEmpty && !widget.isFeatured) {
          print('⚠️ No banners for module, trying featured...');
          return await _fetchFeaturedBanners();
        }

        final List<String> banners = data.map<String>((b) {
          final img = b['image']?.toString() ?? '';

          // ✅ Deteksi format Laravel
          final isLaravelPattern =
              RegExp(r'^\d{4}-\d{2}-\d{2}-[a-z0-9]+\.(png|jpg|jpeg|webp)$')
                  .hasMatch(img);

          final url = isLaravelPattern
              ? 'https://dash.ditokoku.id/storage/app/public/banner/$img'
              : 'https://apinew.ditokoku.id/uploads/banners/$img';

          print('🖼️  Banner: $img → $url');
          return url;
        }).toList();

        return banners;
      } else {
        print('❌ Error response: ${res.statusCode} - ${res.body}');
        return [];
      }
    } catch (e) {
      print('💥 Exception: $e');
      return [];
    }
  }

  // ✅ Helper function untuk fetch featured banners
  Future<List<String>> _fetchFeaturedBanners() async {
    try {
      const apiUrl = 'https://apinew.ditokoku.id/api/banners/ditokoku/featured';
      final res = await http.get(Uri.parse(apiUrl));
      
      if (res.statusCode == 200) {
        final jsonData = json.decode(res.body);
        final List data = jsonData['data'] ?? [];

        return data.map<String>((b) {
          final img = b['image']?.toString() ?? '';
          final isLaravelPattern =
              RegExp(r'^\d{4}-\d{2}-\d{2}-[a-z0-9]+\.(png|jpg|jpeg|webp)$')
                  .hasMatch(img);

          return isLaravelPattern
              ? 'https://dash.ditokoku.id/storage/app/public/banner/$img'
              : 'https://apinew.ditokoku.id/uploads/banners/$img';
        }).toList();
      }
      return [];
    } catch (e) {
      print('💥 Exception fetching featured: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: _futureBanners,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: CircularProgressIndicator(color: Theme.of(context).primaryColor),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink(); // ✅ Tidak tampilkan apa-apa jika kosong
        }

        final banners = snapshot.data!;
        return Column(
          children: [
            CarouselSlider.builder(
              itemCount: banners.length,
              itemBuilder: (context, index, realIdx) {
                final imageUrl = banners[index];
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 6,
                        offset: Offset(0, 3),
                      )
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
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
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          child: const Center(
                            child: Icon(Icons.broken_image, color: Colors.grey, size: 50),
                          ),
                        );
                      },
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
                    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 3),
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