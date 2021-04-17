import 'package:injectable/injectable.dart';
import 'package:mcnd_mobile/core/pair.dart';
import 'package:mcnd_mobile/data/models/api/api_featured_media.dart';
import 'package:mcnd_mobile/data/models/api/api_news_post.dart';
import 'package:mcnd_mobile/data/models/app/featured_media.dart';
import 'package:mcnd_mobile/data/models/app/news_post.dart';
import 'package:mcnd_mobile/data/models/mappers/mapper.dart';
import 'package:mcnd_mobile/data/network/mcnd_api.dart';

@lazySingleton
class NewsService {
  final McndApi _api;
  final Mapper _mapper;

  NewsService(this._api, this._mapper);

  Future<List<Pair<NewsPost, FeaturedMedia>>> getNewsPosts() async {
    final List<ApiNewsPost> apiPosts = await _api.getNewsPosts();
    return (await Future.wait(
      apiPosts.map((apiPost) async {
        final ApiFeaturedMedia media = await _api.getFeaturedMedia(apiPost.featuredMedia);
        return Pair(
          _mapper.mapApiNewsPost(apiPost),
          _mapper.mapApiFeaturedMedia(media),
        );
      }),
    ))
        .toList();
  }
}
