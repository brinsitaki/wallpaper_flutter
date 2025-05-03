import 'package:flutter/material.dart';
import 'package:marnihub/screens/about_screen.dart';
import 'package:marnihub/screens/show_wallpaper_screen.dart';
import 'package:marnihub/services/api_services.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _controller = TextEditingController();
  String _searchText = '';
  final ApiServices _apiServices = ApiServices();
  Future<List<dynamic>>? _images;

  @override
  void initState() {
    super.initState();
    _images = _apiServices.fetchImages();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height / 25,
              ),
              Center(
                child: RichText(
                  text: const TextSpan(
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    children: <TextSpan>[
                      TextSpan(text: 'Marni'),
                      TextSpan(
                        text: 'Hub',
                        style: TextStyle(color: Color(0xFFAD4716)),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height / 25,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: TextField(
                  controller: _controller,
                  onChanged: (value) {
                    setState(() {
                      _searchText = value;
                    });
                  },
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    hintText: 'Search ...',
                    suffixIcon: IconButton(
                      icon: const Icon(
                        Icons.search,
                        color: Color(0xFFAD4716),
                      ),
                      onPressed: () {
                        // Perform search operation with _searchText
                        debugPrint('Search pressed with: $_searchText');
                        setState(() {
                          _images = _apiServices.searchImages(_searchText);
                        });
                      },
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height / 35,
              ),
              Center(
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (context) => const AboutScreen()),
                    );
                  },
                  child: RichText(
                    text: const TextSpan(
                      style: TextStyle(
                        color: Colors.black,
                      ),
                      children: <TextSpan>[
                        TextSpan(text: 'Made by '),
                        TextSpan(
                          text: 'Mohamed Taki Allah Brinsi',
                          style: TextStyle(
                            color: Color(0xFFAD4716),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height / 25,
              ),
              FutureBuilder<List<dynamic>>(
                future: _images,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No images found'));
                  } else {
                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2),
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) => InkWell(
                        onTap: () {
                          //Navigator.of(context).pushNamed("/show_wallpaper");
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ShowWallpaperScreen(
                                      wallpaper: snapshot.data![index]['src']
                                          ['large'],
                                    )),
                          );
                        },
                        child: Card(
                          child: Image.network(
                            snapshot.data![index]['src']['portrait'],
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    );
                  }
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
