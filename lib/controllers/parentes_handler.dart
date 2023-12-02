import 'package:pbd_escolar/interfaces/handler_interface.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

class ParentesHandler extends HandlerInterface {
  @override
  Router get handler {
    final router = Router();

    router.all('/<ignored|.*>', notFound);

    return router;
  }
}
