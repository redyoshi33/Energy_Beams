//
//  ViewController.swift
//  Pending
//
//  Created by jojoestar on 3/8/18.
//  Copyright © 2018 jojoestar. All rights reserved.
//

import UIKit
import CoreMotion
import AVFoundation

class ViewController: UIViewController {
    @IBOutlet weak var countDownLabel: UILabel!
    @IBOutlet weak var powerLabel: UILabel!
    
    @IBAction func Timerbtn(_ sender: UIButton) {
        if timer == nil {
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(update), userInfo: nil, repeats: true)
            startReadingMotionData()
            xmax = 0.0
            ymax = 0.0
            zmax = 0.0
            playSound()
        }
        if blinktimer == nil {
            blinktimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(flicker), userInfo: nil, repeats: true)
        }
        toggleTorch(on: false)
    }
    var motionManager = CMMotionManager()
    let opQueue = OperationQueue()
    var hiddencount = 7
    var count = 5
    var xmax = 0.0
    var ymax = 0.0
    var zmax = 0.0
    var timer: Timer? = nil
    var blinktimer: Timer? = nil
    var audioPlayer:AVAudioPlayer!
    override func viewDidLoad() {
        super.viewDidLoad()
        powerLabel.isHidden = true
        if motionManager.isDeviceMotionAvailable {
            print("We can detect device motion")
        }
        else {
            print("We cannot detect device motion")
        }
    }
    func toggleTorch(on: Bool) {
        guard let device = AVCaptureDevice.default(for: .video) else { return }
        
        if device.hasTorch {
            do {
                try device.lockForConfiguration()
                if on == true {
                    device.torchMode = .on
                } else {
                    device.torchMode = .off
                }
                device.unlockForConfiguration()
            } catch {
                print("Torch could not be used")
            }
        } else {
            print("Torch is not available")
        }
    }
    func playSound() {
        
        let audioFilePath = Bundle.main.path(forResource: "Kame Hame Ha - Sound Effect 5", ofType: "mp3")
        
        if audioFilePath != nil {
            
            let audioFileUrl = NSURL.fileURL(withPath: audioFilePath!)
            do{
                audioPlayer = try AVAudioPlayer(contentsOf: audioFileUrl)
                audioPlayer.play()
            }
            catch{
                print("audio file cannot play")
            }
        }
        else {
            print("audio file is not found")
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @objc func flicker(){
        toggleTorch(on: true);
        toggleTorch(on: false);
    }
    @objc func update(){
        if(hiddencount > 0){
            if count == 2 {
                if blinktimer != nil{
                    blinktimer!.invalidate()
                    blinktimer = nil
                }
            }
            if count == 1{
            toggleTorch(on: true)
            countDownLabel.isHidden = true
            }
            count -= 1
            hiddencount -= 1
            countDownLabel.text = String(count)
        }
        else{
            stoptimer()
            countDownLabel.text = String(count)
            motionManager.stopDeviceMotionUpdates()
            var total = xmax
            if total < ymax {
                total = ymax
            }
            if total < zmax {
                total = zmax
            }
            total *= 1000
            let power = Int(total)
            if power > 9000 {
                powerLabel.text = "IT'S OVER 9000!!: "+String(power)
            }
            else{
                powerLabel.text = "Power Levels: "+String(power)
            }
            powerLabel.isHidden = false

        }
    }
    func stoptimer(){
        if timer != nil {
            timer!.invalidate()
            timer = nil
            hiddencount = 7
            count = 5
            countDownLabel.isHidden = false
        }
    }
    func startReadingMotionData() {
        // set read speed
        motionManager.deviceMotionUpdateInterval = 0.1
        // start reading
        motionManager.startDeviceMotionUpdates(to: opQueue) {
            (data: CMDeviceMotion?, error: Error?) in
            if let mydata = data {
                if self.xmax < mydata.userAcceleration.x{
                    self.xmax = mydata.userAcceleration.x
                }
                if self.ymax < mydata.userAcceleration.y{
                    self.ymax = mydata.userAcceleration.y
                }
                if self.zmax < mydata.userAcceleration.z{
                    self.zmax = mydata.userAcceleration.z
                }
            }
        }
    }
}
