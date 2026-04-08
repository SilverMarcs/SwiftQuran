//
//  LocationManager.swift
//  SwiftQuran
//
//  Created by Zabir Raihan on 18/07/2025.
//

import MapKit

@Observable
class LocationManager: NSObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    private var continuation: CheckedContinuation<CLLocationCoordinate2D?, Never>?
    private var timeoutTask: Task<Void, Never>?

    override init() {
        super.init()
        manager.delegate = self
        // Prayer times are city-level — no need for high accuracy, and a coarse fix returns much faster.
        manager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
    }

    func requestLocation() async -> CLLocationCoordinate2D? {
        // Re-entry guard: if a request is already in flight, don't stomp on its continuation.
        if continuation != nil {
            print("[LocationManager] requestLocation called while another is in flight — rejecting")
            return nil
        }

        print("[LocationManager] requestLocation, current status: \(manager.authorizationStatus.rawValue)")

        return await withCheckedContinuation { continuation in
            self.continuation = continuation
            startTimeout()

            switch manager.authorizationStatus {
            case .notDetermined:
                print("[LocationManager] requesting authorization")
                #if os(macOS)
                manager.requestAlwaysAuthorization()
                #else
                manager.requestWhenInUseAuthorization()
                #endif
                // Wait for locationManagerDidChangeAuthorization to fire.
            case .authorizedWhenInUse, .authorizedAlways:
                print("[LocationManager] already authorized, starting updates")
                manager.startUpdatingLocation()
            case .denied, .restricted:
                print("[LocationManager] denied/restricted")
                finish(with: nil)
            @unknown default:
                finish(with: nil)
            }
        }
    }

    private func startTimeout() {
        timeoutTask?.cancel()
        timeoutTask = Task { [weak self] in
            try? await Task.sleep(for: .seconds(20))
            guard !Task.isCancelled else { return }
            await MainActor.run {
                guard let self else { return }
                if self.continuation != nil {
                    print("[LocationManager] timeout waiting for location fix")
                    self.finish(with: nil)
                }
            }
        }
    }

    private func finish(with coordinate: CLLocationCoordinate2D?) {
        timeoutTask?.cancel()
        timeoutTask = nil
        manager.stopUpdatingLocation()
        continuation?.resume(returning: coordinate)
        continuation = nil
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("[LocationManager] didUpdateLocations: \(locations.count) locations")
        guard let location = locations.first else { return }
        finish(with: location.coordinate)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // kCLErrorLocationUnknown means "can't get a fix yet, will keep trying" — ignore and wait.
        if let clError = error as? CLError, clError.code == .locationUnknown {
            print("[LocationManager] locationUnknown — ignoring, still trying")
            return
        }
        print("[LocationManager] error: \(error)")
        finish(with: nil)
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        print("[LocationManager] auth changed to: \(manager.authorizationStatus.rawValue)")

        // Only act if a request is currently waiting on us.
        guard continuation != nil else { return }

        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            manager.startUpdatingLocation()
        case .denied, .restricted:
            finish(with: nil)
        case .notDetermined:
            // Prompt still showing — keep waiting.
            break
        @unknown default:
            finish(with: nil)
        }
    }
}
