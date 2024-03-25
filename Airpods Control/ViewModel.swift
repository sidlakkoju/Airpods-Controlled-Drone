//
//  AirPodsMotionViewModel.swift
//  Airpods Control
//
//  Created by Siddharth Lakkoju on 3/20/24.
//

import Foundation
import CoreMotion
import Combine
import SceneKit

class ViewModel: ObservableObject {
    private let motionManager = CMHeadphoneMotionManager()
    @Published var motionData: String = "Looking for Airpods Pro"
    @Published var cubeRotation: Array<Double> = [0.0, 0.0, 0.0]
    @Published var direction: String = "idle"
    private var socketManager: SocketManager?
}



// AirPods orientations tuff
extension ViewModel {
    
    func startMonitoring() {
        guard motionManager.isDeviceMotionAvailable else {
            motionData = "Sorry, device not supported"
            return
        }
        motionManager.startDeviceMotionUpdates(to: OperationQueue.current!) { [weak self] (motion, error) in
            guard let motion = motion, error == nil else { return }
            DispatchQueue.main.async {
                self?.updateMotionData(motion)
            }
        }
    }
    
    
    func stopMonitoring() {
        motionManager.stopDeviceMotionUpdates()
    }
    
    
    func updateMotionData(_ data: CMDeviceMotion) {
        cubeRotation[0] = data.attitude.pitch
        cubeRotation[1] = data.attitude.yaw
        cubeRotation[2] = data.attitude.roll
        motionData = getMotionDataString(data)
        updateDirection(data)
    }
    
    
    private func updateDirection(_ motion: CMDeviceMotion) {
        let pitch = motion.attitude.pitch
        let roll = motion.attitude.roll
        
        let pitchThreshold = 0.20
        let rollThreshold = 0.25
        
        if pitch > (pitchThreshold - 0.05){
            if direction != "backward" {
                backward()
            }
            direction = "backward"
        }
        else if pitch < -pitchThreshold{
            if direction != "forward"{
                forward()
            }
            direction = "forward"
        }
        else if roll > rollThreshold {
            if direction != "right" {
                right()
            }
            direction = "right"
        }
        else if roll < -rollThreshold {
            if direction != "left" {
                left()
            }
            direction = "left"
        }
        else {
            if direction != "idle" {
                stop()
            }
            direction = "idle"
        }
    }
}



// Tello stuff
extension ViewModel {
    func setupTello() {
        socketManager = SocketManager()
    }
    func takeOff() {
        socketManager?.sendCommand(command: "takeoff")
    }
    
    func land() {
        socketManager?.sendCommand(command: "land")
    }
    func forward() {
        socketManager?.sendCommand(command: "rc 0 70 0 0")   // left/right, f/b, u/p, yaw
    }
    func backward() {
        socketManager?.sendCommand(command: "rc 0 -70 0 0")
    }
    func right() {
        socketManager?.sendCommand(command: "rc 0 0 0 80")
    }
    func left() {
        socketManager?.sendCommand(command: "rc 0 0 0 -80")
    }
    func stop() {
//        socketManager?.sendCommand(command: "stop")
        socketManager?.sendCommand(command: "rc 0 0 0 0")
    }
    func emergency() {
        socketManager?.sendCommand(command: "emergency")
    }
}



// Util functions
extension ViewModel {
    func getMotionDataString(_ data: CMDeviceMotion) -> String {
        let motionData: String = """
        Quaternion:
            x: \(data.attitude.quaternion.x)
            y: \(data.attitude.quaternion.y)
            z: \(data.attitude.quaternion.z)
            w: \(data.attitude.quaternion.w)
        Attitude:
            pitch: \(data.attitude.pitch)
            roll: \(data.attitude.roll)
            yaw: \(data.attitude.yaw)
        Gravitational Acceleration:
            x: \(data.gravity.x)
            y: \(data.gravity.y)
            z: \(data.gravity.z)
        Rotation Rate:
            x: \(data.rotationRate.x)
            y: \(data.rotationRate.y)
            z: \(data.rotationRate.z)
        Acceleration:
            x: \(data.userAcceleration.x)
            y: \(data.userAcceleration.y)
            z: \(data.userAcceleration.z)
        Magnetic Field:
            field: \(data.magneticField.field)
            accuracy: \(data.magneticField.accuracy)
        Heading:
            \(data.heading)
        """
        return motionData
    }
}
