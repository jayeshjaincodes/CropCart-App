import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {
  Future<Position?> getCurrentPosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Geolocator.openLocationSettings();
      return Future.error('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied.');
    }

    // Get the current position
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  Future<String> _getPlacemarkProperty(Position position, String property) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        switch (property) {
          case 'street':
            return placemarks[0].street ?? 'Street not found';
          case 'subLocality':
            return placemarks[0].subLocality ?? 'Sub-locality not found';
          case 'locality':
            return placemarks[0].locality ?? 'Locality not found';
          case 'administrativeArea':
            return placemarks[0].administrativeArea ?? 'Administrative area not found';
          case 'postalCode':
            return placemarks[0].postalCode ?? 'Postal code not found';
          case 'country':
            return placemarks[0].country ?? 'Country not found';
          case 'thoroughfare':
            return placemarks[0].thoroughfare ?? 'Thoroughfare not found';
          case 'name':
            return placemarks[0].name ?? 'Name not found';
          default:
            return 'Property not found';
        }
      } else {
        return 'No placemark found for the location';
      }
    } catch (e) {
      return 'Failed to get $property: $e';
    }
  }

  Future<String> getFullAddress(Position position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        return '${place.street ?? ''}, ${place.name ?? ''}, ${place.thoroughfare ?? ''}, ${place.subLocality ?? ''}, ${place.locality ?? ''}, ${place.administrativeArea ?? ''}-${place.postalCode ?? ''}, ${place.country ?? ''}';
      } else {
        return 'No address found for the location';
      }
    } catch (e) {
      return 'Failed to get address: $e';
    }
  }

  Future<String> getStreet(Position position) => _getPlacemarkProperty(position, 'street');
  Future<String> getSubLocality(Position position) => _getPlacemarkProperty(position, 'subLocality');
  Future<String> getLocality(Position position) => _getPlacemarkProperty(position, 'locality');
  Future<String> getAdministrativeArea(Position position) => _getPlacemarkProperty(position, 'administrativeArea');
  Future<String> getPostalCode(Position position) => _getPlacemarkProperty(position, 'postalCode');
  Future<String> getCountry(Position position) => _getPlacemarkProperty(position, 'country');
  Future<String> getThoroughfare(Position position) => _getPlacemarkProperty(position, 'thoroughfare');
  Future<String> getName(Position position) => _getPlacemarkProperty(position, 'name');

  // New methods to get city and pincode (postal code)
  Future<String> getCity(Position position) async {
    return await getLocality(position); // Locality often corresponds to the city
  }

  Future<String> getPincode(Position position) async {
    return await getPostalCode(position);
  }
}
