//
//  GameViewController.swift
//  game4
//
//  Created by Erik Bean on 11/22/15.
//  Copyright (c) 2015 Erik Bean. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {
    
    @IBOutlet weak var pauseScreen: UIView!
    @IBOutlet weak var pauseGame: UILabel!
    @IBOutlet weak var quitRestart: UIButton!
    
    let loggingMode = NSUserDefaults.standardUserDefaults().boolForKey("bug_mode")

    override func viewDidLoad() {
        super.viewDidLoad()
        
        pauseScreen.hidden = true
        
        let scene = GameScene(size: view.bounds.size)
        let skView = view as! SKView
        if loggingMode {
            skView.showsFPS = true
            skView.showsNodeCount = true
        }
        skView.ignoresSiblingOrder = true
        scene.scaleMode = .ResizeFill
        scene.backgroundColor = UIColor.blackColor()
        skView.presentScene(scene)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        pauseScreen.hidden = true
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        pauseScreen.hidden = false
    }
    
    @IBAction func doesWantToQuit(sender: AnyObject) {
            performSegueWithIdentifier("home", sender: self)
    }

    override func shouldAutorotate() -> Bool {
        return true
    }

    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return .AllButUpsideDown
        } else {
            return .All
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
