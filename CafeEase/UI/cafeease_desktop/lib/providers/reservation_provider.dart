import '../models/reservation.dart';
import 'base_provider.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ReservationProvider extends BaseProvider<Reservation> {
  ReservationProvider() : super('api/Reservations');

  @override
  Reservation fromJson(data) {
    return Reservation.fromJson(data);
  }

  Future<void> cancelReservation(int id, String reason) async {
    final uri = Uri.parse('${BaseProvider.baseUrl}api/Reservations/$id/cancel');

    final response = await http.post(
      uri,
      headers: createHeaders(),
      body: jsonEncode({"cancellationReason": reason}),
    );

    isValidResponse(response);
  }
}
