//
//  TVGameController.swift
//  EndlessVoid
//
//  Created by Erik Bean on 11/27/15.
//  Copyright (c) 2015 Erik Bean. All rights reserved.
//

import UIKit
import SpriteKit

class TVGameController: UIViewController {

    @IBOutlet weak var pauseScreen: UIView!
    @IBOutlet weak var pauseText: UILabel!
    
    let loggingMode = true //NSUserDefaults.standardUserDefaults().boolForKey("bug_mode")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pauseScreen.hidden = true
        
        let scene = TVGameScene(size: view.bounds.size)
        let skView = self.view as! SKView
        if loggingMode {
            skView.showsFPS = true
            skView.showsNodeCount = true
        }
        skView.ignoresSiblingOrder = true
        scene.scaleMode = .AspectFill
        scene.backgroundColor = .blackColor()
        skView.presentScene(scene)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func doesWantToQuit(sender: AnyObject) {
        
    }
    
    @IBAction func doesWantToResume(sender: AnyObject) {
        pauseScreen.hidden = true
    }
    
}
