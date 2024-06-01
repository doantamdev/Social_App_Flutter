import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../Models/post.dart';
import '../DetailPhotoScreen.dart';
import 'ModalListComment‎.dart';
import 'imageAvatar.dart';

class PostItem extends StatelessWidget{
  final Post post;
  const PostItem({super.key, required this.post});

  Widget buildImagesContainer(BuildContext context){
    return post.images.isNotEmpty ? InkWell(
      onTap: (){
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => DetailPhotoScreen(images: post.images,)),
        );
      },
      child: Container(
        height: 200,
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
            image: DecorationImage(
                colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.6), BlendMode.darken),
                image: NetworkImage(post.images[0].path),
                fit: BoxFit.fill
            ),
            borderRadius: BorderRadius.circular(4)),
        child: Center(
          child: Text('+${post.images.length.toString()}', style: const TextStyle(fontSize: 30, color: Colors.white),),
        ),
      ),
    ) : Text('');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border.all(color: Colors.blueAccent),
          borderRadius: BorderRadius.circular(10)
      ),
      child: Column(
        children: [
          Row(
            children: [
              ImageAvatar(imageUrl: post.imageUrl, maxRadius: 25,),
              const SizedBox(
                width: 8,
              ),
              Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(post.displayName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,),
                      Row(
                        children: [
                          Text(timeago.format(post.created)),
                          const SizedBox(
                            width: 5,
                          ),
                          const Icon(Icons.public, size: 15,)
                        ],
                      )
                    ],
                  )
              ),

            ],
          ),
          Container(
            padding: const EdgeInsets.all(5),
            child: RichText(
              text: TextSpan(
                text:post.noiDung ?? '',
                style: DefaultTextStyle.of(context).style,
              ),
            ),
          ),
          buildImagesContainer(context),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(
                    Icons.thumb_up_rounded,
                    color: Colors.blue,
                    size: 18,
                  ),
                  Text('22')
                ],
              ),
              Row(
                children: [
                  Text('${post.comments.length} comments'),
                  const SizedBox(
                    width: 5,
                  ),
                  const Text('30 shared')
                ],
              ),
            ],
          ),
          SizedBox(
            height: 8,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(Icons.thumb_up_alt_outlined),
                  Text('Like')
                ],
              ),
              InkWell(
                onTap: (){
                  showModalBottomSheet(
                    isScrollControlled: true,
                    context: context,
                    builder: (BuildContext context) {
                      return SizedBox(
                          height: MediaQuery.of(context).size.height - kToolbarHeight,
                          child: ModalListComment(postId: post.id, totalComments: post.comments.length,)
                      );
                    },
                  );
                },
                child: Row(
                  children: const [
                    Icon(Icons.comment),
                    Text('Comments')
                  ],
                ),
              ),
              Row(
                children: const [
                  Icon(Icons.share),
                  Text('Share')
                ],
              ),
            ],
          )
        ],
      ),
    );
  }
}