//
//  ViewController.swift
//  CrazyFlieTestApp
//
//  Created by 0xff on 15/08/2019.
//  Copyright © 2019 Volaly. All rights reserved.
//

import UIKit
import simd

import CrazyFlieKit

func rad2deg<T: FloatingPoint>(_ rad: T) -> T {
    return (rad * 180 / .pi)
}

func deg2rad<T: FloatingPoint>(_ deg: T) -> T {
    return (deg / 180 * .pi)
}

class ViewController: UIViewController, StopWatchDelegate {
    @IBOutlet weak var cfX: UITextField!
    @IBOutlet weak var cfY: UITextField!
    @IBOutlet weak var cfZ: UITextField!
    @IBOutlet weak var cfRoll: UITextField!
    @IBOutlet weak var cfPitch: UITextField!
    @IBOutlet weak var cfYaw: UITextField!
    @IBOutlet weak var statsWindow: UITextField!
    @IBOutlet weak var statsHz: UITextField!
    @IBOutlet weak var cfConnect: UIButton!

    var crazyFlie: CrazyFlie?
    var stopWatch: StopWatch!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        stopWatch = StopWatch(maxWindow: 100, statsInterval: 0.1, delegate: self)

        crazyFlie = CrazyFlie(delegate: nil)
    }

    @IBAction func cfConnectPressed(_ sender: Any) {
        guard let cf = crazyFlie else {return}

        if case .idle = cf.state {
            cf.connect { connected in
                if connected {
                    self.cfConnect.setTitle("Disconnect", for: .normal)
                    print("Connected to CrazyFlie")
                    self.cfDidConnect()
                } else {
                    self.cfConnect.setTitle("Connect", for: .normal)
                    print("Disconnected from Crazyflie")
                    self.cfDidDisconnect()
                }
            }
        } else {
            guard let cf = crazyFlie else {return}
            cf.genericStop { _ in
                cf.disconnect()
            }
            return
        }
    }

    func cfDidConnect() {
        guard let cf = crazyFlie else {return}

        DispatchQueue.global().async {
            cf.fetchTocs()

            guard let log = cf.log else {return}

            log.createBlock(vars: ["stateEstimate/x", "stateEstimate/y", "stateEstimate/z", "range/zrange"],
                            period: 1/30.0,
                            didUpdate: self.cfDidUpdateOdom)

            log.createBlock(vars: ["stateEstimate/qx", "stateEstimate/qy", "stateEstimate/qz", "stateEstimate/qw"],
                            period: 1/30.0,
                            didUpdate: self.cfDidUpdateOrientation)

            log.createBlock(vars: ["kalman/inFlight", "sys/canfly", "stabilizer/thrust", "pm/state", "pm/batteryLevel"],
                            period: 1.0,
                            didUpdate: self.cfDidUpdateState)
        }

    }

    func cfDidDisconnect() {

    }

    func cfResetKalman() {
        guard let cf = crazyFlie else {return}
        guard cf.state == .connected else {return}
        guard let ps = cf.paramStore else {return}

        ps.paramsByName["stabilizer/estimator"]?.value   = UInt8(2) // 1 - Complementary estimator, 2 - EKF
        ps.paramsByName["stabilizer/controller"]?.value  = UInt8(1) // 1 - PID controller, 2 - Mellinger

        ps.paramsByName["kalman/resetEstimation"]?.value = UInt8(1)
        ps.paramsByName["kalman/resetEstimation"]?.value = UInt8(0)
    }

    func cfDidUpdateOdom(logBlock: LogBlock) {
        stopWatch.hz()
        let x = logBlock.values["stateEstimate/x"] as! Float32
        let y = logBlock.values["stateEstimate/y"] as! Float32
        let z = logBlock.values["stateEstimate/z"] as! Float32

        self.cfX.text = String(format: "%3.3f", x)
        self.cfY.text = String(format: "%3.3f", y)
        self.cfZ.text = String(format: "%3.3f", z)
    }

    func cfDidUpdateOrientation(logBlock: LogBlock) {
        let qx = logBlock.values["stateEstimate/qx"] as! Float32
        let qy = logBlock.values["stateEstimate/qy"] as! Float32
        let qz = logBlock.values["stateEstimate/qz"] as! Float32
        let qw = logBlock.values["stateEstimate/qw"] as! Float32

        let quat = simd_quatf(ix: qx, iy: qy, iz: qz, r: qw)
        let (r, p, y) = quat.rpy

        self.cfRoll.text  = String(format: "%3.2f", rad2deg(r))
        self.cfPitch.text = String(format: "%3.2f", rad2deg(p))
        self.cfYaw.text   = String(format: "%3.2f", rad2deg(y))
    }

    func cfDidUpdateState(logBlock: LogBlock) {
        let batteryLevel: UInt8 = logBlock.values["pm/batteryLevel"] as! UInt8

        print("Battery: \(batteryLevel)%")
    }

    func stopWatch(_ stopWatch: StopWatch, window: Int, didEstimateHz value: Double) {
        self.statsWindow.text = String(format: "%d", window)
        self.statsHz.text = String(format: "%3.2f", value)
    }

    func stopWatch(_ stopWatch: StopWatch, window: Int, didEstimateTime value: CFTimeInterval) {
        
    }
}

