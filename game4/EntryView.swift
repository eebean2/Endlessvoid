//
//  EntryView.swift
//  game4
//
//  Created by Erik Bean on 11/27/15.
//  Copyright © 2015 Erik Bean. All rights reserved.
//

import UIKit
import SpriteKit

class EntryView: UIViewController {
    
    @IBOutlet weak var titleText: UILabel!
    @IBOutlet weak var playRestart: UIButton!
    @IBOutlet weak var howToPlay: UIButton!
    @IBOutlet weak var options: UIButton!
    
    var timer: NSTimer!
    var checkTimer: NSTimer!
    var scene = SKScene()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let gameOver = NSUserDefaults.standardUserDefaults().boolForKey("GameOver")
        if gameOver {
            let gameScene = GameScene()
            gameScene.removeFromParent()
        }
        NSUserDefaults.standardUserDefaults().setBool(false, forKey: "GameOver")
        
        titleText.text = "The Endless Void"
        titleText.sizeToFit()
        playRestart.setTitle("Play", forState: UIControlState.Normal)
        
        // View Code Here
        
        scene = SKScene(size: view.bounds.size)
        scene.backgroundColor = .blackColor()
        let skView = view as! SKView
        skView.presentScene(scene)
        
        // Scene Code Here
        
        createPool()
        let interval = NSTimeInterval.init(0.3)
        checkTimer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: #selector(EntryView.checkSnowflakeBounds), userInfo: nil, repeats: true)
        timer = NSTimer.scheduledTimerWithTimeInterval(interval, target: self, selector: #selector(EntryView.spawnCircle), userInfo: nil, repeats: true)
        timer.fire()
        scene.physicsWorld.gravity = CGVectorMake(0.0, -1)
    }
    
    var pool = Array<SKShapeNode>()
    var inPool = Array<Int>()
    var snow1 = UIImage(named: "snowflake1")
    var snow2 = UIImage(named: "snowflake2")
    var snow3 = UIImage(named: "snowflake3")
    var snow4 = UIImage(named: "snowflake4")
    
    func createPool() {
        for i in 0 ..< 15 {
            let circle = SKShapeNode(circleOfRadius: 3)
            circle.fillColor = .whiteColor()
            circle.strokeColor = .clearColor()
            circle.name = "\(i)"
            
            let randImage = arc4random_uniform(5)
            var image = UIImage()
            if randImage == 0 {
                image = snow1!
            } else if randImage == 1 {
                image = snow2!
            } else if randImage == 2 {
                image = snow3!
            } else {
                image = snow4!
            }
            circle.fillTexture = SKTexture(image: image)
            
            circle.physicsBody = SKPhysicsBody(circleOfRadius: 3)
            circle.physicsBody?.dynamic = true
            circle.physicsBody?.velocity = CGVectorMake(0, -5)
            pool.append(circle)
        }
    }
    
    func spawnCircle() {
        var randCircle = arc4random_uniform(UInt32(15))
        print("Random Number = \(randCircle)")
        while inPool.contains(Int(randCircle)) {
            randCircle = arc4random_uniform(UInt32(15))
            print("Random Redrawn = \(randCircle)")
        }
        let node = pool[Int(randCircle)]
        inPool.append(Int(node.name!)!)
        print(inPool)
        var placement = arc4random_uniform(UInt32(scene.frame.width))
        while placement < 10 {
            placement = arc4random_uniform(UInt32(scene.frame.width))
        }
        node.position = CGPoint(x: CGFloat(placement - 10), y: scene.frame.height + 75)
        scene.addChild(node)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func shouldAutorotate() -> Bool {
        return true
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return.AllButUpsideDown
        } else {
            return .All
        }
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return false
    }
    
    func checkSnowflakeBounds() {
        for node in pool {
            if node.position.y < 0 {
                if inPool.contains(Int(node.name!)!) {
                    print("Removing: \(node.name!)")
                    inPool.removeAtIndex(inPool.indexOf(Int(node.name!)!)!)
                    node.removeFromParent()
                }
            }
        }
    }
    
    @IBAction func play(sender: AnyObject) {
        pool.removeAll()
        timer.invalidate()
        checkTimer.invalidate()
        performSegueWithIdentifier("play", sender: self)
    }
}
