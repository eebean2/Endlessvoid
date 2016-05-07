//
//  GameScene.swift
//  EndlessVoid
//
//  Created by Erik Bean on 11/27/15.
//  Copyright (c) 2015 Erik Bean. All rights reserved.
//

import SpriteKit
import AVFoundation

class TVGameScene: SKScene, SKPhysicsContactDelegate {
    
    // MARK: Variables
    
    let loggingMode = true //NSUserDefaults.standardUserDefaults().boolForKey("bug_mode")
    let locationLab = SKLabelNode()
    var user = SKShapeNode()
    var circle = SKShapeNode()
    var circleDir = Dictionary<String, SKShapeNode>()
    var audioPlayer: AVAudioPlayer!
    var timer: NSTimer!
    var gamePlaying = false
    var music = false
    var gameOver = false
    
    // MARK: didMoveToView
    
    override func didMoveToView(view: SKView) {
        
        let path = NSBundle.mainBundle().pathForResource("Christmas Songs - Christmas Songs", ofType: "mp3")
        let url = NSURL(fileURLWithPath: path!)
        gamePlaying = true
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOfURL: url)
            audioPlayer.play()
            music = true
        } catch {
            print("Can't play music file")
        }
        
        locationLab.position = CGPoint(x: CGRectGetMinX(self.frame) + 60, y: CGRectGetMinY(self.frame) + 20)
        if loggingMode {
            locationLab.fontColor = .whiteColor()
            locationLab.fontSize = 25
            locationLab.text = "(0,0)"
        }
        addChild(locationLab)
        
        physicsWorld.gravity = CGVectorMake(0.0, -1)
        physicsWorld.contactDelegate = self
        
        drawUser()
        randomizer()
        drawCircle()
    }

    
    // MARK: Circles
    
    func randomizer() {
        drawCircle()
        let interval = NSTimeInterval.init(0.25)
        timer = NSTimer.scheduledTimerWithTimeInterval(interval, target: self, selector: "drawCircle", userInfo: nil, repeats: true)
    }
    
    func drawUser() {
        let cat1:UInt32 = 0x1 << 0
        let cat2:UInt32 = 0x1 << 1
        user = SKShapeNode(rectOfSize: CGSize(width: 25, height: 30))
        user.fillColor = .whiteColor()
        user.position = CGPoint(x: CGRectGetMidX(frame), y: CGRectGetMinY(frame) + 45)
        user.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: 25, height: 25))
        user.physicsBody?.dynamic = false
        user.physicsBody?.affectedByGravity = false
        user.physicsBody?.velocity = CGVectorMake(0,0)
        user.physicsBody?.allowsRotation = false
        user.physicsBody?.categoryBitMask = cat1
        user.physicsBody?.contactTestBitMask = cat2
        user.name = "User"
        addChild(user)
    }
    
    func drawCircle() {
        let cat1:UInt32 = 0x1 << 0
        let cat2:UInt32 = 0x1 << 1
        var random = arc4random_uniform(UInt32(frame.width))
        while CGFloat(random) < 10 {
            random = arc4random_uniform(UInt32(frame.width))
        }
        circle = SKShapeNode(circleOfRadius: 50)
        circle.fillColor = .whiteColor()
        let randomImage = arc4random_uniform(5)
        var image = UIImage()
        if randomImage == 0 {
            image = UIImage(named: "snowflake1")!
        } else if randomImage == 1 {
            image = UIImage(named: "snowflake2")!
        } else if randomImage == 2 {
            image = UIImage(named: "snowflake3")!
        } else {
            image = UIImage(named: "snowflake4")!
        }
        let texture = SKTexture(image: image)
        circle.fillTexture = texture
        circle.strokeColor = .clearColor()
        circle.position = CGPoint(x: CGFloat(random - 10), y: frame.height + 75)
        circle.physicsBody = SKPhysicsBody(circleOfRadius: 50)
        circle.physicsBody?.dynamic = true
        circle.physicsBody?.velocity = CGVectorMake(0, -5)
        circle.physicsBody?.categoryBitMask = cat2
        circle.physicsBody?.contactTestBitMask = cat1
        let nameRandomizer = arc4random_uniform(12)
        circle.name = "Circle_\(nameRandomizer)_\(circle.position.x)"
        circleDir["\(circle.name)"] = circle
        addChild(circle)
    }
    
    // MARK: Touch and Contact
    
    // MARK: -
    // TODO: Remove comment lines in didBeginContact
    // MARK: -
    
    func didBeginContact(contact: SKPhysicsContact) {
        
        let circleObject = contact.bodyB
        let temp = circleObject.node
        let circleToChange = temp as! SKShapeNode
//        circleToChange.fillColor = .blackColor()
        circleToChange.strokeColor = .whiteColor()
//         user.fillColor = .blackColor()
//        backgroundColor = .whiteColor()
        gameOver = true
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        let userLocation = touches.first?.locationInNode(self)
        
        if !timer.valid {
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
        
        if loggingMode {
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
        
        if loggingMode {
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
    
    // MARK: Frame Updates
    
    override func update(currentTime: CFTimeInterval) {
        for node in circleDir {
            let circleNode = node.1
            let circleName = node.0
            if circleNode.position.y < 0 {
                circleDir.removeValueForKey("\(circleName)")
                circleNode.fillTexture = nil
                circleNode.removeFromParent()
            }
        }
    }
    
    // MARK: Game Over
    
    func endGame() {
        if timer.valid {
            timer.invalidate()
        }
        audioPlayer.stop()
        physicsWorld.speed = 0.0
    }
}
