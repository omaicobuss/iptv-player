import '../../../core/models/channel.dart';
import '../../../core/utils/m3u_parser.dart';

class M3uPlaylistRepository {
  const M3uPlaylistRepository();

  List<Channel> loadFromString(String content) {
    return parseM3U(content);
  }
}
