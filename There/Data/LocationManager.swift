import CoreLocation
import Foundation

final class LocationManager: NSObject, CLLocationManagerDelegate, ObservableObject {
    @Published var lastKnownLocation: CLLocationCoordinate2D?
    @Published var cityName: String?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var errorMessage: String?
    
    private var manager: CLLocationManager?
    
    override init() {
        super.init()
        print("LocationManager initialized")
        setupLocationManager()
    }
    
    private func setupLocationManager() {
        print("Setting up CLLocationManager")
        manager = CLLocationManager()
        manager?.delegate = self
        checkLocationAuthorization()
    }
    
    func checkLocationAuthorization() {
        guard let manager = manager else {
            print("CLLocationManager is nil")
            errorMessage = "Location manager not initialized"
            return
        }
        
        print("Checking location authorization")
        authorizationStatus = manager.authorizationStatus
        
        switch authorizationStatus {
        case .notDetermined, .denied:
            print("Location access not determined or denied")
            errorMessage = "Location access not enabled. Please enable in System Preferences."
        case .restricted:
            print("Location access restricted")
            errorMessage = "Location access is restricted"
        case .authorizedAlways:
            print("Location authorized, requesting location")
            manager.requestLocation()
        default:
            print("Unknown authorization status")
            errorMessage = "Unknown location authorization status"
        }
    }

    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        print("Authorization status changed to: \(manager.authorizationStatus.rawValue)")
        checkLocationAuthorization()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("Did update locations: \(locations)")
        if let location = locations.first {
            lastKnownLocation = location.coordinate
            getCityName(from: location)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager failed with error: \(error.localizedDescription)")
        errorMessage = "Failed to get location: \(error.localizedDescription)"
    }
    
    func getCityName(from location: CLLocation) {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
            if let error = error {
                print("Reverse geocoding error: \(error.localizedDescription)")
                self.errorMessage = "Failed to get city name: \(error.localizedDescription)"
                return
            }
            
            if let placemark = placemarks?.first {
                self.cityName = placemark.locality ?? placemark.subAdministrativeArea ?? placemark.administrativeArea
                print("City name updated: \(self.cityName ?? "Unknown")")
            }
        }
    }
}
