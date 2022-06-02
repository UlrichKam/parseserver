import 'package:flutter/material.dart';
import 'package:parseserver/main.dart';
import 'package:parseserver/models/api_image_model.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:parseserver/providers/auth_provider.dart';
import 'package:provider/provider.dart';


class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<ApiImage> images = [];

  @override
  void initState() {
    super.initState();
    initStateAsyncFunction();
  }

  void initStateAsyncFunction() async {
    images = await getImagesFromAPI(numberOfElements: 10);
    setState(() {});
  }

  Future<List<ApiImage>> getImagesFromAPI(
      {required int numberOfElements}) async {
    List<ApiImage> output = [];
    Uri url = Uri.parse("https://jsonplaceholder.typicode.com/photos");
    http.Response response = await http.get(url);

    if (response.statusCode == 200) {
      List<dynamic> result = jsonDecode(response.body);
      for (var element in result) {
        output.add(
          ApiImage(
              albumId: element["albumId"],
              title: element["title"],
              url: element["url"],
              thumbnailUrl: element["thumbnailUrl"]),
        );
      }
      return output.sublist(0, numberOfElements);
    } else if (response.statusCode >= 100 && response.statusCode < 200) {
      return Future.error('Http Request Informational Response');
    } else if (response.statusCode > 200 && response.statusCode < 300) {
      return Future.error('Http Request Successful (But not 200) Response');
    } else if (response.statusCode >= 300 && response.statusCode < 400) {
      return Future.error('Http Request Redirection Message');
    } else if (response.statusCode >= 400 && response.statusCode < 500) {
      return Future.error('Http Request Error Response');
    } else if (response.statusCode >= 500 && response.statusCode < 600) {
      return Future.error('Http Request Server Error Response');
    } else {
      return Future.error('Http Request unknown error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(" Welcome ${context.watch<Auth>().user?.username}"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          ElevatedButton(
              onPressed: (){
                Provider.of<Auth>(context, listen: false).user?.logout();
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) => const Authentication()));
              }, child: const Text("Sign Out")
          ),
          Expanded(
            child: ListView.builder(
              itemCount: images.length,
              itemBuilder: (BuildContext context, int index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18.0),
                  child: PhotoListCard(image: images[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class PhotoListCard extends StatelessWidget {
  final ApiImage image;
  const PhotoListCard({Key? key, required this.image}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: (){
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) => ImageDetail(image: image)));
      },
      child: Card(
          child: Column(
            children: [
              SizedBox(
                  height: 150,
                  width: 150,
                  child: Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Image.network(
                      image.url,
                      fit: BoxFit.fill,
                      loadingBuilder: (BuildContext context, Widget child,
                          ImageChunkEvent? loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        );
                      },
                    ),
                  ),
              ),
              Padding(
                padding: const EdgeInsets.all(18.0),
                child: Text(image.title),
              ),
            ],
          ),
      ),
    );
  }

}

class ImageDetail extends StatelessWidget {
  const ImageDetail({Key? key, required this.image}) : super(key: key);
  final ApiImage image;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Image Details"),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: ()=>Navigator.of(context).pop(),
        ),
      ),

      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  const Text("Title", style: TextStyle(fontWeight: FontWeight.bold),),
                  Text(image.title),
                ],
              ),
              Column(
                children: [
                  const Text("thumbnailUrl", style: TextStyle(fontWeight: FontWeight.bold),),
                  Text(image.thumbnailUrl),
                ],
              ),
              Column(
                children: [
                  const Text("albumId", style: TextStyle(fontWeight: FontWeight.bold),),
                  Text("${image.albumId}"),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
