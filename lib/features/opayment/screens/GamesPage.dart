import 'package:flutter/material.dart';
import 'GameTopUpPage.dart';

class GamesPage extends StatefulWidget {
  const GamesPage({super.key});

  @override
  State<GamesPage> createState() => _GamesPageState();
}

class _GamesPageState extends State<GamesPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Data untuk produk games
  final List<Map<String, dynamic>> gameProducts = [
    {
      'name': 'Free Fire',
      'description': 'Top up Diamond Free Fire',
      'logoPath': 'assets/image/freefire_logo.png',
    },
    {
      'name': 'Mobile Legends',
      'description': 'Top up Diamond Mobile Legends',
      'logoPath': 'assets/image/mobilelegends_logo.png',
    },
    {
      'name': 'PUBG Mobile',
      'description': 'Top up UC PUBG Mobile',
      'logoPath': 'assets/image/pubgmobile_logo.png',
    },
    {
      'name': 'Google Play',
      'description': 'Google Play Gift Card Indonesia',
      'logoPath': 'assets/image/googleplay_logo.jpeg',
    },
    {
      'name': 'iTunes',
      'description': 'Apple Gift Card / iTunes',
      'logoPath': 'assets/image/itunes_logo.png',
    },
    {
      'name': 'PlayStation',
      'description': 'PlayStation Network (PSN)',
      'logoPath': 'assets/image/playstation_logo.png',
    },
    {
      'name': 'Steam Wallet',
      'description': 'Steam Wallet IDR',
      'logoPath': 'assets/image/steamwallet_logo.png',
    },
    {
      'name': 'Razer Gold',
      'description': 'Top up Razer Gold',
      'logoPath': 'assets/image/razergold_logo.jpeg',
    },
    {
      'name': 'UniPin',
      'description': 'UniPin Voucher',
      'logoPath': 'assets/image/unipin_logo.png',
    },
    {
      'name': 'Garena',
      'description': 'Garena Shells / Voucher',
      'logoPath': 'assets/image/garena_logo.jpg',
    },
    {
      'name': 'Gemscool',
      'description': 'Gemscool G-Cash',
      'logoPath': 'assets/image/gemscool_logo.jpeg',
    },
    {
      'name': 'Lyto',
      'description': 'Lyto Cash / Credits',
      'logoPath': 'assets/image/lyto_logo.png',
    },
    {
      'name': 'Megaxus',
      'description': 'Megaxus MI-Cash',
      'logoPath': 'assets/image/megaxus_logo.png',
    },
    {
      'name': 'IAHGames',
      'description': 'Top up IAHGames',
      'logoPath': 'assets/image/iahgames_logo.jpeg',
    },
    {
      'name': 'Asiasoft',
      'description': 'Asiasoft @Cash',
      'logoPath': 'assets/image/asiasoft_logo.jpg',
    },
    {
      'name': 'Wave Game',
      'description': 'Wave Point',
      'logoPath': 'assets/image/wavegame_logo.jpg',
    },
    {
      'name': 'Digicash',
      'description': 'Digicash Voucher',
      'logoPath': 'assets/image/digicash_logo.png',
    },
    {
      'name': 'Point Blank',
      'description': 'Point Blank (Zepetto) - PB Cash',
      'logoPath': 'assets/image/pointblank_logo.jpeg',
    },
    {
      'name': 'Roblox',
      'description': 'Roblox Robux Gift Card',
      'logoPath': 'assets/image/roblox_logo.png',
    },
    {
      'name': 'Valorant',
      'description': 'Valorant (Riot) Points',
      'logoPath': 'assets/image/valorant_logo.png',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get filteredProducts {
    if (_searchQuery.isEmpty) {
      return gameProducts;
    }
    return gameProducts.where((product) {
      final name = product['name'].toString().toLowerCase();
      final description = product['description'].toString().toLowerCase();
      final query = _searchQuery.toLowerCase();
      return name.contains(query) || description.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Image.asset(
            'assets/image/goback.png',
            width: 28,
            height: 28,
            fit: BoxFit.contain,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Games',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(20),
            color: Colors.white,
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Cari game atau voucher...',
                hintStyle: TextStyle(color: Colors.grey[400]),
                prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, color: Colors.grey[400]),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),

          // Product List
          Expanded(
            child: filteredProducts.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Game tidak ditemukan',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.all(20),
                    child: ListView.separated(
                      itemCount: filteredProducts.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        return _buildGameCard(filteredProducts[index]);
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameCard(Map<String, dynamic> product) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GameTopUpPage(
              gameName: product['name'],
              gameDescription: product['description'],
              logoPath: product['logoPath'],
              gameId: _getGameId(product['name']),
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Logo container
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                product['logoPath'],
                width: 50,
                height: 50,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.sports_esports,
                      color: Colors.grey[400],
                      size: 24,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 16),
            
            // Product info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product['name'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product['description'],
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            
            // Arrow icon
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey[400],
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  String _getGameId(String gameName) {
    final gameIdMap = {
      'Free Fire': 'freefire',
      'Mobile Legends': 'mobilelegends',
      'PUBG Mobile': 'pubgmobile',
      'Google Play': 'googleplay',
      'iTunes': 'itunes',
      'PlayStation': 'playstation',
      'Steam Wallet': 'steam',
      'Razer Gold': 'razergold',
      'UniPin': 'unipin',
      'Garena': 'garena',
      'Gemscool': 'gemscool',
      'Lyto': 'lyto',
      'Megaxus': 'megaxus',
      'IAHGames': 'iahgames',
      'Asiasoft': 'asiasoft',
      'Wave Game': 'wavegame',
      'Digicash': 'digicash',
      'Point Blank': 'pointblank',
      'Roblox': 'roblox',
      'Valorant': 'valorant',
    };
    
    return gameIdMap[gameName] ?? gameName.toLowerCase().replaceAll(' ', '');
  }
}