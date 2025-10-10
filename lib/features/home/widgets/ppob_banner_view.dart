import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PpobBannerView extends StatefulWidget {
  const PpobBannerView({super.key});

  @override
  State<PpobBannerView> createState() => _PpobBannerViewState();
}

class _PpobBannerViewState extends State<PpobBannerView> {
  int _currentIndex = 0;
  bool _isLoading = true;
  List<Map<String, dynamic>> _banners = [];

  @override
  void initState() {
    super.initState();
    _loadBanners();
  }

  Future<void> _loadBanners() async {
    try {
      final response = await http.get(
        Uri.parse('https://api.ditokoku.id/api/banners?is_active=1'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        
        if (jsonData['status'] == true && jsonData['data'] != null) {
          setState(() {
            _banners = List<Map<String, dynamic>>.from(jsonData['data']);
            _isLoading = false;
          });
        } else {
          setState(() {
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_banners.isEmpty && !_isLoading) {
      return const SizedBox();
    }

    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.width * 0.45,
      padding: const EdgeInsets.only(top: Dimensions.paddingSizeSmall),
      child: !_isLoading ? Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: CarouselSlider.builder(
              options: CarouselOptions(
                autoPlay: true,
                enlargeCenterPage: false,
                disableCenter: true,
                viewportFraction: 1,
                autoPlayInterval: const Duration(seconds: 7),
                onPageChanged: (index, reason) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
              ),
              itemCount: _banners.isEmpty ? 1 : _banners.length,
              itemBuilder: (context, index, _) {
                final banner = _banners[index];
                final imageUrl = banner['url'] ?? '';
                
                return Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                    boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 0)],
                  ),
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[200],
                          child: const Center(
                            child: Icon(Icons.broken_image, color: Colors.grey, size: 50),
                          ),
                        );
                      },
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
                    ),
                  ),
                );
              },
            ),
          ),
          
          const SizedBox(height: Dimensions.paddingSizeExtraSmall),
          
          // Indicator mirip BannerView
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: _banners.asMap().entries.map((entry) {
              int index = entry.key;
              int totalBanner = _banners.length;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: index == _currentIndex 
                  ? Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor, 
                        borderRadius: BorderRadius.circular(Dimensions.radiusDefault)
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      child: Text(
                        '${index + 1}/$totalBanner', 
                        style: robotoRegular.copyWith(
                          color: Theme.of(context).cardColor, 
                          fontSize: 12
                        )
                      ),
                    )
                  : Container(
                      height: 5, 
                      width: 6,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withValues(alpha: 0.5), 
                        borderRadius: BorderRadius.circular(Dimensions.radiusDefault)
                      ),
                    ),
              );
            }).toList(),
          ),
        ],
      ) : Shimmer(
        duration: const Duration(seconds: 2),
        enabled: _isLoading,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
            color: Colors.grey[300],
          ),
        ),
      ),
    );
  }
}