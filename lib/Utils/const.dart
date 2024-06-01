import '../Views/ChatScreen.dart';
import '../Views/FeedScreen.dart';
import '../Views/GroupScreen.dart';
import '../Views/ProfileScreen.dart';

List pages = [
  const ChatScreen(),
  const GroupScreen(),
  const FeedScreen(),
  const ProfileScreen()
];


const serverName = "10.0.2.2"; //10.0.2.2 for mobile or localhost for desktop app
const urlBase = "http://$serverName:5291";
const hubUrl = "http://$serverName:5291/hubs/";


final List<String> iconsCustom = [
  '😊','😆','😅','🤣','😂','😍','😘', '❤️','💘','🐶','🐵','🦊','🐴','🐷','🐔'
];

const appId = "64118cdfe0004fbdae809c3896762609";// agora app id

