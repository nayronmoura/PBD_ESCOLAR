import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

abstract class HandlerInterface {
  Router get handler;

  Response notFound(Request request) => Response.notFound('Page not found');
}
