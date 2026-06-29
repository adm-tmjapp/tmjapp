import 'package:location/location.dart';

class LocationApp
{
    Location location = Location();

    late bool _serviceEnabled;
    late PermissionStatus _permissionGranted;

    Future<LocationData> get locationData async
    {
        return await location.getLocation();
    }

    Future<bool> requestPermissionLocation() async
    {
        _serviceEnabled = await location.serviceEnabled();
        if (!_serviceEnabled)
        {
            _serviceEnabled = await location.requestService();
            if (!_serviceEnabled)
            {
                return false;
            }
        }

        _permissionGranted = await location.hasPermission();
        if (_permissionGranted == PermissionStatus.denied)
        {
            _permissionGranted = await location.requestPermission();
            if (_permissionGranted != PermissionStatus.granted)
            {
                return false;
            }
        }
        return true;
    }
}
