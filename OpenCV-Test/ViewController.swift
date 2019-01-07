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
    let openCv = OpenCVWrapper()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        openCv.createCamera(withParentView: imgView)
        openCv.param["l_threshold"] = 128
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        openCv.start()
    }
    
    @IBAction func threshold_l_changed(_ sender: UISlider) {
        openCv.param["l_threshold"] = sender.value
    }
}

