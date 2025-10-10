import 'package:flutter/material.dart';
import 'PulsaDataPage.dart'; 
import 'UangElektronikPage.dart';
import 'PLNPage.dart';
import 'GamesPage.dart';
import 'InternetTVPage.dart';
import 'PDAMPage.dart';
import 'PascabayarHPPage.dart';




class SemuaProdukPage extends StatefulWidget {
  const SemuaProdukPage({super.key});

  @override
  State<SemuaProdukPage> createState() => _SemuaProdukPageState();
}

class _SemuaProdukPageState extends State<SemuaProdukPage> {
  int selectedTabIndex = 0;
  
  final List<String> tabs = ['Semua', 'Daily', 'Bills', 'Entertainment'];

  // Data untuk setiap kategori
  final Map<String, List<Map<String, dynamic>>> categoryData = {
    'Favorit Saya': [
      {'icon': Icons.wifi, 'label': 'Internet &\nTV Kabel', 'color': Colors.blue},
      {'icon': Icons.smartphone, 'label': 'Pulsa &\nData', 'color': Colors.blue},
      {'icon': Icons.account_balance_wallet, 'label': 'Uang\nElektronik', 'color': Colors.blue},
    ],
    'Daily': [
      {'icon': Icons.smartphone, 'label': 'Pulsa &\nData', 'color': Colors.blue},
      {'icon': Icons.account_balance_wallet, 'label': 'Uang\nElektronik', 'color': Colors.blue},
    ],
    'Bills': [
      {'icon': Icons.water_drop, 'label': 'Air', 'color': Colors.blue},
      {'icon': Icons.bolt, 'label': 'Listrik PLN', 'color': Colors.blue},
      {'icon': Icons.wifi, 'label': 'Internet &\nTV Kabel', 'color': Colors.blue},
      {'icon': Icons.smartphone, 'label': 'Pasca\nBayar', 'color': Colors.blue},
    ],
    'Entertainment': [
      {'icon': Icons.sports_esports, 'label': 'Games', 'color': Colors.blue},
    ],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Semua Produk',
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
          // Tab bar
          Container(
            color: Colors.white,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                children: List.generate(tabs.length, (index) {
                  final isSelected = selectedTabIndex == index;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedTabIndex = index;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.blue : Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(
                          color: isSelected ? Colors.blue : Colors.grey[300]!,
                        ),
                      ),
                      child: Text(
                        tabs[index],
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.grey[600],
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
          
          // Content
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: _buildCategoryContent(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildCategoryContent() {
    List<Widget> content = [];
    
    if (selectedTabIndex == 0) {
      // Semua - tampilkan semua kategori
      categoryData.forEach((categoryName, items) {
        content.add(_buildCategorySection(categoryName, items));
        content.add(const SizedBox(height: 32));
      });
    } else {
      // Tab spesifik
      String selectedCategory = tabs[selectedTabIndex];
      if (categoryData.containsKey(selectedCategory)) {
        content.add(_buildCategorySection(selectedCategory, categoryData[selectedCategory]!));
      }
    }
    
    return content;
  }

  Widget _buildCategorySection(String title, List<Map<String, dynamic>> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.85,
          ),
          itemCount: items.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            return _buildMenuItem(
              icon: items[index]['icon'],
              label: items[index]['label'],
              color: items[index]['color'],
             onTap: () {
  // Check if the clicked item is "Pulsa & Data"
  if (items[index]['label'] == 'Pulsa &\nData') {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PulsaDataPage(),
      ),
    );
  } else if (items[index]['label'] == 'Uang\nElektronik') {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const UangElektronikPage(),
      ),
    );
  } else if (items[index]['label'] == 'Listrik PLN') {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PLNPage(),
      ),
    );
    } 
    
    
    else if (items[index]['label'] == 'Games') {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const GamesPage(),
    ),
  );
} else if (items[index]['label'] == 'Internet &\nTV Kabel') {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const InternetTVPage(),
      ),
    );
  }
  else if (items[index]['label'] == 'Air') {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PDAMPage(),
      ),
    );
  }
 else if (items[index]['label'] == 'Pasca\nBayar') {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PascabayarHPPage(),
      ),
    );
  }
else {
    print('${items[index]['label']} clicked');
    // Add navigation logic for other items here
  }
},
            );
          },
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.15),
                  spreadRadius: 1,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: color,
              size: 28,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black87,
              height: 1.2,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}