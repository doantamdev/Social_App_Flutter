
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:social_app/Views/widgets/imageAvatar.dart';

import '../Utils/global.dart';
import '../services/postService.dart';

class AddPostScreen extends StatefulWidget{
  const AddPostScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return AddPostScreenState();
  }
}

class AddPostScreenState extends State<AddPostScreen>{
  final TextEditingController contentController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  List<XFile>? images;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add post'),
        actions: [
          IconButton(
              onPressed: (){
                PostService().savePost(files: images, content: contentController.text)
                    .then((value) => Fluttertoast.showToast(
                    msg: value,
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.green,
                    textColor: Colors.white,
                    fontSize: 16.0
                ));
              },
              icon: const Icon(Icons.save)
          )
        ],
      ),
      body: Container(
        margin: const EdgeInsets.all(8),
        child: Column(
          children: [
            Row(
              children: [
                ImageAvatar(imageUrl: Global.user!.imageUrl, maxRadius: 25,),
                const SizedBox(width: 8,),
                Text(Global.user!.displayName, style: const TextStyle(fontWeight: FontWeight.bold),),
              ],
            ),
            const SizedBox(height: 10,),
            TextField(
              controller: contentController,
              keyboardType: TextInputType.multiline,
              minLines: 10,
              maxLines: 10,
              decoration: const InputDecoration(
                  hintText: "Write content..."
              ),
            ),
            IconButton(
                onPressed: () async{
                  //image = await _picker.pickImage(source: ImageSource.gallery);
                  images = await _picker.pickMultiImage();
                },
                icon: const Icon(Icons.image)
            )
          ],
        ),
      ),
    );
  }
}