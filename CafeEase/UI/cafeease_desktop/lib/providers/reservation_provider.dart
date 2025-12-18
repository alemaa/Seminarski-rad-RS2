import '../models/reservation.dart';
import 'base_provider.dart';

class ReservationProvider extends BaseProvider<Reservation> {
  ReservationProvider() : super('api/Reservations');

  @override
  Reservation fromJson(data) {
    return Reservation.fromJson(data);
  }
}
