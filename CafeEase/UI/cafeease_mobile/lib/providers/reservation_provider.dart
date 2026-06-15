import '../models/reservation.dart';
import 'base_provider.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ReservationProvider extends BaseProvider<Reservation> {
  ReservationProvider() : super("api/Reservations");

  @override
  Reservation fromJson(data) => Reservation.fromJson(data);

  Future<Reservation> create({
    required int tableNumber,
    required DateTime reservationDateTime,
    required int numberOfGuests,
  }) async {
    final req = {
      "tableNumber": tableNumber,
      "reservationDateTime": reservationDateTime.toUtc().toIso8601String(),
      "numberOfGuests": numberOfGuests,
    };
    return await insert(req);
  }

  Future<List<Reservation>> getForDate(DateTime date) async {
    final res = await get(filter: {
      "date": date.toIso8601String(),
    });
    return res.result;
  }

  Future<void> updateReservation(int id,
      {DateTime? reservationDateTime,
      int? numberOfGuests,
      String? status}) async {
    final req = <String, dynamic>{};
    if (reservationDateTime != null) {
      req["reservationDateTime"] = reservationDateTime.toUtc().toIso8601String();
    }

    if (numberOfGuests != null) {
      req["numberOfGuests"] = numberOfGuests;
    }

    if (status != null) {
      req["status"] = status;
    }

    await updateVoid(id, req);
  }

  Future<void> cancelReservation(int id, String reason) async {
    final uri = Uri.parse('${BaseProvider.baseUrl}api/Reservations/$id/cancel');

    final response = await http.post(
      uri,
      headers: createHeaders(),
      body: jsonEncode({
        "cancellationReason": reason,
      }),
    );

    isValidResponse(response);
  }
}
