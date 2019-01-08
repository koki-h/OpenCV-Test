//
//  ViewController.swift
//  OpenCV-Test
//
//  Created by koki on 2019/01/02.
//  Copyright © 2019 koki. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var swMode: UISwitch!
    @IBOutlet weak var slThresholdLight: UISlider!
    let openCv = OpenCVWrapper()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        openCv.createCamera(withParentView: imgView)
        openCv.param["slider_value"] = 128
        openCv.param["filter_on"] = false
        swMode.isOn = openCv.param["filter_on"] as! Bool
        slThresholdLight.value = Float(openCv.param["slider_value"] as! Int)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        openCv.start()
    }
    
    @IBAction func threshold_l_changed(_ sender: UISlider) {
        openCv.param["slider_value"] = Int(sender.value)
    }
    
    @IBAction func switchMode(_ sender: UISwitch) {
        openCv.param["filter_on"] = sender.isOn
    }
    
    @IBAction func tapCameraSwitch(_ sender: Any) {
        openCv.toggleCameraPosition()
    }
}

