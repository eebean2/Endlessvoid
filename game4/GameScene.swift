//
//  GameScene.swift
//  game4
//
//  Created by Erik Bean on 11/22/15.
//  Copyright (c) 2015 Erik Bean. All rights reserved.
//

import SpriteKit
import AVFoundation

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // MARK: -
    // TODO: Update file structure
    // MARK: -
    
    let loggingmode = NSUserDefaults.standardUserDefaults().boolForKey("bug_mode")
    let locationLab = SKLabelNode()
    var audioPlayer: AVAudioPlayer!
    var gamePlaying = false
    var music = false
    
    override func didMoveToView(view: SKView) {
        
        createPool()
        spawnCircle()
        
        let path = NSBundle.mainBundle().pathForResource("Christmas Songs - Christmas Songs", ofType: "mp3")
        let url = NSURL(fileURLWithPath: path!)
        gamePlaying = true
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOfURL: url)
            audioPlayer.play()
            music = true
        } catch {
            print("Can't Play File")
        }
        
        if loggingmode {
            locationLab.position = CGPoint(x: CGRectGetMinX(self.frame) + 60, y: CGRectGetMinY(self.frame) + 20)
            locationLab.fontColor = SKColor.whiteColor()
            locationLab.fontSize = 14
            locationLab.text = "(0,0)"
            self.addChild(locationLab)
        }
        
        physicsWorld.gravity = CGVectorMake(0.0, -1)
        physicsWorld.contactDelegate = self
        
        drawUser()
        randomizer()
    }
    
    var timer:NSTimer!
    
    func randomizer() {
        spawnCircle()
        let interval = NSTimeInterval.init(0.5)
        timer = NSTimer.scheduledTimerWithTimeInterval(interval, target: self, selector: #selector(GameScene.spawnCircle), userInfo: nil, repeats: true)
        timer.fire()
    }
    
    var gameOver = false
    var user = SKShapeNode()
    
    // MARK: User
    
    func drawUser() {
        let cat1:UInt32 = 0x1 << 0
        let cat2:UInt32 = 0x1 << 1
        user = SKShapeNode(rectOfSize: CGSize(width: 25, height: 30))
        user.fillColor = SKColor.whiteColor()
        user.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMinY(self.frame) + 45)
        user.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: 25, height: 25))
        user.physicsBody?.dynamic = false
        user.physicsBody?.affectedByGravity = false 
        user.physicsBody?.velocity = CGVectorMake(0,0)
        user.physicsBody?.allowsRotation = false
        user.physicsBody?.categoryBitMask = cat1
        user.physicsBody?.contactTestBitMask = cat2
        user.name = "User"
        self.addChild(user)
    }
    
    // MARK: Circles
    
    // Circles moved to bottom of file for now
    
    func didBeginContact(contact: SKPhysicsContact) {
        
        let circleObject = contact.bodyB
        let temp = circleObject.node
        let circleToChange = temp as! SKShapeNode
        circleToChange.fillColor = .blackColor()
        circleToChange.strokeColor = .blackColor()
        user.fillColor = .blackColor()
        backgroundColor = .whiteColor()
        gameOver = true
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let userLocation = touches.first?.locationInNode(self)
        
        if !timer.valid && !gameOver {
            randomizer()
        }
        
        if !music {
            audioPlayer.play()
        }
        
        if !gamePlaying {
            gamePlaying = true
        }
        
        if !gameOver {
            user.position = userLocation!
        }
        
        if loggingmode {
            let location = (CGPoint(x: userLocation!.x, y: userLocation!.y))
            locationLab.text = "\(location)"
        }
        
        physicsWorld.speed = 1.0
    }
   
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let userLocation = touches.first?.locationInNode(self)
        
        if !gameOver {
            user.position = userLocation!
        } else {
            endGame()
        }
        
        if loggingmode {
            let location = (CGPoint(x: userLocation!.x, y: userLocation!.y))
            locationLab.text = "\(location)"
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        physicsWorld.speed = 0.0
        gamePlaying = false
        music = false
        audioPlayer.pause()
        if timer.valid {
            timer.invalidate()
        }
    }
    
    func endGame() {
        timer.invalidate()
        audioPlayer.stop()
        pool.removeAll()
        inPool.removeAll()
        physicsWorld.speed = 0.0
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: "GameOver")
    }
    
    override func update(currentTime: NSTimeInterval) {
        if gameOver {
            endGame()
        }
        
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
    
    func restart() {
        
    }
    
    
    var pool = Array<SKShapeNode>()
    var inPool = Array<Int>()
    var snow1 = UIImage(named: "snowflake1")
    var snow2 = UIImage(named: "snowflake2")
    var snow3 = UIImage(named: "snowflake3")
    var snow4 = UIImage(named: "snowflake4")
    
    func createPool() {
        for i in 0 ..< 15 {
            let circle = SKShapeNode(circleOfRadius: 50)
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
            
            let cat1 : UInt32 = 0x1 << 0
            let cat2 : UInt32 = 0x1 << 1
            
            circle.physicsBody = SKPhysicsBody(circleOfRadius: 50)
            circle.physicsBody?.dynamic = true
            circle.physicsBody?.velocity = CGVectorMake(0, -5)
            circle.physicsBody?.categoryBitMask = cat2
            circle.physicsBody?.contactTestBitMask = cat1
            pool.append(circle)
            
            print(circle)
        }
    }
    
    func spawnCircle() {
        var randCircle = arc4random_uniform(UInt32(15))
        print("Random Number = \(randCircle)")
        while inPool.contains(Int(randCircle)) {
            randCircle = arc4random_uniform(UInt32(15))
            print("Random Redrawn = \(randCircle)")
        }
        print(randCircle)
        let chosen = Int(randCircle)
        let node = pool[chosen]
        inPool.append(Int(node.name!)!)
        print(inPool)
        var placement = arc4random_uniform(UInt32(self.frame.width))
        while placement < 10 {
            placement = arc4random_uniform(UInt32(self.frame.width))
        }
        node.position = CGPoint(x: CGFloat(placement - 10), y: self.frame.height + 75)
        self.addChild(node)
    }
}
