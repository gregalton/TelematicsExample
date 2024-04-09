//
//  TelematicsManager.swift
//  TelematicsExample
//
//  Created by Greg Alton on 3/28/24.
//

import SwiftUI
import CoreLocation
import CoreMotion
import AVFoundation

class TelematicsManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    static let shared = TelematicsManager()
    
    private let locationManager = CLLocationManager()
    private let motionManager = CMMotionManager()
    private var isMonitoringMotion = false
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        
        // Ensure location services are enabled and we have the necessary permission
        if CLLocationManager.locationServicesEnabled() && (status == .authorizedWhenInUse || status == .authorizedAlways) {
            locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
            locationManager.startUpdatingLocation()
        } else {
            // Handle lack of permission or disabled location services as needed
        }
        
        // For debugging
        switch manager.authorizationStatus {
            case .authorizedWhenInUse:  // Location services are available.
                //enableLocationFeatures()
                print("Location Manager status: .authorizedWhenInUse")
                break
                
            case .restricted, .denied:  // Location services currently unavailable.
                //disableLocationFeatures()
                print("Location Manager status: .restricted, .denied")
                break
                
            case .notDetermined:        // Authorization not determined yet.
                print("Location Manager status: .notDetermined. Trying again.")
            manager.requestAlwaysAuthorization()
                break
                
            default:
                break
            }
        
        // Similarly, for CoreMotion, ensure you have the necessary permissions if required
        // iOS does not currently require explicit permission for CoreMotion at the time of writing,
        // but this may change, and best practice is to check documentation and system behavior
    }
    
    func startTracking() {
//        if CLLocationManager.locationServicesEnabled() {
//            locationManager.startUpdatingLocation()
//        } else {
//            print("Location Services are unavailable.")
//        }
    }
    
    private func isDriving(speed: CLLocationSpeed) -> Bool {
        // Assuming driving at speeds greater than 20 km/h (5.56 m/s).
        return speed > 5.56
    }
    
    func listAvailableVoices() {
        let voices = AVSpeechSynthesisVoice.speechVoices()
        for voice in voices {
            print("Voice: \(voice.name), Language: \(voice.language)")
        }
    }
    
    private func startMonitoringDeviceMotion() {
            guard !isMonitoringMotion else { return }
            
            isMonitoringMotion = true
            motionManager.deviceMotionUpdateInterval = 1.0 // Update every 1 second (adjust as needed)
            
            motionManager.startDeviceMotionUpdates(to: .main) { [weak self] (motion, error) in
                guard let strongSelf = self, let motion = motion else { return }
                
                // Process motion data to detect potential distracted driving behaviors here
                // For example, significant phone movement or orientation changes
                
                // Example placeholder condition
                if motion.userAcceleration.x > 0.5 {
                    strongSelf.warnDistractedDriving()
                }
            }
        }
    
    private func stopMonitoringDeviceMotion() {
        guard isMonitoringMotion else { return }
        
        isMonitoringMotion = false
        motionManager.stopDeviceMotionUpdates()
    }
    
    private func warnDistractedDriving() {
        // https://developer.apple.com/documentation/avfoundation/speech_synthesis/
        let utterance = AVSpeechUtterance(string: "Distracted driving is dangerous.")
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        
        // Create a speech synthesizer.
        let synthesizer = AVSpeechSynthesizer()


        // Tell the synthesizer to speak the utterance.
        synthesizer.speak(utterance)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let speed = locations.last?.speed else { return }
        
        if isDriving(speed: speed) {
            startMonitoringDeviceMotion()
        } else {
            stopMonitoringDeviceMotion()
        }
    }
}

