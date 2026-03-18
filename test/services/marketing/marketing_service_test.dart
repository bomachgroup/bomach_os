import 'package:bms_front_end/src/services/marketing/marketing_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';

void main() {
  late Dio dio;
  late DioAdapter dioAdapter;
  late MarketingService service;
  const token = 'test-token';

  setUp(() {
    dio = Dio(BaseOptions(
        baseUrl: 'https://bomachauth.bgbot.app/api/v1'));
    dioAdapter = DioAdapter(dio: dio);
    service = MarketingService(dioOverride: dio);
  });

  final sampleCampaign = {
    'id': 1,
    'name': 'Q1 Campaign',
    'description': 'Test campaign',
    'status': 'active',
    'channel': 'social_media',
    'impressions': 50000,
    'ctr': '2.5',
    'roi': '150.0',
    'progress_percentage': '65.0',
    'budget_allocated': '1000000',
    'budget_spent': '650000',
    'budget_remaining': '350000',
    'budget_utilization_percentage': 65.0,
    'is_over_budget': false,
    'clicks': 1250,
    'start_date': '2026-01-01',
    'end_date': '2026-03-31',
    'created_at': '2026-01-01T00:00:00Z',
    'updated_at': '2026-01-01T00:00:00Z',
  };

  final sampleContent = {
    'id': 1,
    'title': 'Blog Post 1',
    'content_type': 'blog_post',
    'status': 'published',
    'platform': 'website',
    'body': 'Content body',
    'excerpt': 'Short excerpt',
    'views': 500,
    'likes': 50,
    'shares': 20,
    'comments': 10,
    'is_featured': true,
    'is_published': true,
    'created_at': '2026-01-01T00:00:00Z',
    'updated_at': '2026-01-01T00:00:00Z',
  };

  group('getCampaigns', () {
    test('returns campaigns from paginated response', () async {
      dioAdapter.onGet(
        '/marketing-campaigns',
        (server) => server.reply(200, {
          'items': [sampleCampaign],
          'count': 1,
        }),
        queryParameters: {'limit': 100, 'offset': 0},
      );

      final result = await service.getCampaigns(token);
      expect(result.items.length, 1);
      expect(result.items.first.name, 'Q1 Campaign');
      expect(result.total, 1);
    });

    test('returns empty when no campaigns', () async {
      dioAdapter.onGet(
        '/marketing-campaigns',
        (server) => server.reply(200, {'items': [], 'count': 0}),
        queryParameters: {'limit': 100, 'offset': 0},
      );

      final result = await service.getCampaigns(token);
      expect(result.items, isEmpty);
    });

    test('throws on error', () async {
      dioAdapter.onGet(
        '/marketing-campaigns',
        (server) => server.reply(500, {'detail': 'Server error'}),
        queryParameters: {'limit': 100, 'offset': 0},
      );
      expect(() => service.getCampaigns(token), throwsA(isA<Exception>()));
    });
  });

  group('createCampaign', () {
    test('creates campaign successfully', () async {
      dioAdapter.onPost(
        '/marketing-campaigns',
        (server) => server.reply(201, sampleCampaign),
        data: Matchers.any,
      );

      final result = await service.createCampaign(token, sampleCampaign);
      expect(result.name, 'Q1 Campaign');
      expect(result.channel, 'social_media');
    });
  });

  group('deleteCampaign', () {
    test('deletes campaign successfully', () async {
      dioAdapter.onDelete(
        '/marketing-campaigns/1',
        (server) => server.reply(200, {'detail': 'Deleted'}),
      );
      await expectLater(service.deleteCampaign(token, 1), completes);
    });
  });

  group('getContent', () {
    test('returns content from paginated response', () async {
      dioAdapter.onGet(
        '/content',
        (server) => server.reply(200, {
          'items': [sampleContent],
          'count': 1,
        }),
        queryParameters: {'limit': 100, 'offset': 0},
      );

      final result = await service.getContent(token);
      expect(result.items.length, 1);
      expect(result.items.first.title, 'Blog Post 1');
    });
  });

  group('createContent', () {
    test('creates content successfully', () async {
      dioAdapter.onPost(
        '/content',
        (server) => server.reply(201, sampleContent),
        data: Matchers.any,
      );

      final result = await service.createContent(token, sampleContent);
      expect(result.title, 'Blog Post 1');
      expect(result.platform, 'website');
    });
  });

  group('deleteContent', () {
    test('deletes content successfully', () async {
      dioAdapter.onDelete(
        '/content/1',
        (server) => server.reply(200, {'detail': 'Deleted'}),
      );
      await expectLater(service.deleteContent(token, 1), completes);
    });
  });
}
