import 'dart:convert';

import 'package:shelf/shelf.dart';

class ResponseFormatter {
  static Response sucess({required dynamic message}) {
    return Response.ok(jsonEncode({'status': 'sucess', 'message': message}));
  }

  static Response internalError({required String message}) {
    return Response.internalServerError(
        body: jsonEncode({'status': 'error', 'message': message}));
  }

  static Response badRequest({required String message}) {
    return Response.badRequest(
        body: jsonEncode({'status': 'error', 'message': message}));
  }

  static Response forbidden({required String message}) {
    return Response.forbidden(
        jsonEncode({'status': 'error', 'message': message}));
  }
}
