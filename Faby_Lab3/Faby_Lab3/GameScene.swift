//
//  GameScene.swift
//  Faby_Lab3
//
//  Created by Joel Shaffer on 2/2/15.
//  Copyright (c) 2015 Joel Shaffer. All rights reserved.
//

import SpriteKit
import Darwin

class GameScene: SKScene, SKPhysicsContactDelegate {
    var gameStatus = "start";
    let startTitle = SKLabelNode(fontNamed:"Chalkduster")
    let faby = SKSpriteNode(imageNamed:"angryBird")
    var soundEffect : SKAction!
    let sparks = SKEmitterNode(fileNamed: "fire")
    let scrollNode = SKNode()
    let bk1 = SKSpriteNode(imageNamed: "angry_background")
    let bk2 = SKSpriteNode(imageNamed: "angry_background")
    let block = SKSpriteNode(imageNamed: "block_trans")
    var blocks : [SKSpriteNode] = []
    let fabyMask : UInt32 = 0x00
    let wallMask : UInt32 = 0x01
    let blockMask : UInt32 = 0x02
    
    
    override func didMoveToView(view: SKView) {
        setupScreen(view)
        setTitle()
        setupPhysics()
        setupBackground()
    }
    
    func setupPhysics() {
        physicsWorld.contactDelegate = self
        let ground_distance : CGFloat = -10.0
        self.physicsBody = SKPhysicsBody(edgeLoopFromRect: CGRectMake(0, ground_distance, self.size.width, self.size.height - ground_distance))
    }
    
    func setupScreen(view:SKView) {
        size = view.frame.size
        self.backgroundColor = UIColor.whiteColor()
    }
    
    func setupBackground() {
        
        
        bk1.anchorPoint = CGPointZero
        bk1.position = CGPointMake(0, 0)
        bk1.zPosition = -15
        scrollNode.addChild(bk1)
//        self.addChild(bk1)
        
        bk2.anchorPoint = CGPointZero
        bk2.position = CGPointMake(bk1.size.width - 1, 0)
        bk2.zPosition = -15
        scrollNode.addChild(bk2)
//        self.addChild(bk2)
        
        self.addChild(scrollNode)
        backgroundImageHandler()
        
    }
    
    override func update(currentTime: NSTimeInterval) {
        if(gameStatus == "playing") {
            backgroundImageHandler()
        }
    }
    
    func backgroundImageHandler() {
        bk1.position = CGPointMake(bk1.position.x - 2, bk1.position.y)
        bk2.position = CGPointMake(bk2.position.x - 2, bk2.position.y)
        
        if(bk1.position.x < -bk1.size.width){
            bk1.position = CGPointMake(bk2.position.x + bk2.size.width, bk1.position.y)
        }
        
        if(bk2.position.x < -bk2.size.width) {
            bk2.position = CGPointMake(bk1.position.x + bk1.size.width, bk2.position.y)
        }
    }
    
    func setupFaby(faby : SKSpriteNode) {
        faby.xScale = 0.25
        faby.yScale = 0.25
        faby.zPosition = 5
        faby.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMaxY(self.frame) * 0.7)
        
        //give faby some physics
        let physicsBody = SKPhysicsBody(circleOfRadius: faby.size.height/2.0)
        physicsBody.affectedByGravity = true
        physicsBody.linearDamping = 0
        
        physicsBody.categoryBitMask = fabyMask
        physicsBody.contactTestBitMask = wallMask | blockMask
        physicsBody.collisionBitMask = wallMask | blockMask
        
        physicsBody.allowsRotation = false
        faby.physicsBody = physicsBody
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        if(gameStatus == "start") {
            startTitle.removeFromParent()
            gameStatus =  "playing"
            
            setupFaby(faby)
            
            //setup audio
            soundEffect = SKAction.playSoundFileNamed("bird-chirp.mp3", waitForCompletion: false)
            
            self.physicsWorld.gravity =  CGVector(dx: 0, dy: -15)
            self.addChild(faby)
        } else if(gameStatus == "playing") {
            //give upwards impulse
            faby.physicsBody?.velocity = CGVector(dx: 0, dy: 600)
            
            //add sound
            runAction(soundEffect)
            
            //add animation
            let addSparks = createSparks()
            runAction(addSparks)
            let timer = NSTimer.scheduledTimerWithTimeInterval(0.25, target: self, selector: Selector("killSparks"), userInfo: nil, repeats: false)
            
            
            //add blocks
            let addBlocks = createBlock()
            runAction(addBlocks)
            
        }
    }
    
    func createSparks() -> SKAction {
        return SKAction.sequence([SKAction.runBlock {
            self.sparks.removeFromParent()
            self.sparks.position = CGPoint(x: self.faby.position.x - 10, y: self.faby.position.y + 20)
            self.sparks.zPosition = 10
            self.addChild(self.sparks)
            }
            ]
        )
    }
    
    func createBlock() -> SKAction {
        return SKAction.sequence(
            [SKAction.runBlock {
                let aBlock = SKSpriteNode(imageNamed: "block_trans")
                aBlock.xScale = 0.5
                aBlock.yScale = 0.5
                let yPos = Float(CGRectGetMaxY(self.frame)) * self.getRandomHeight()
                aBlock.position = CGPoint(x: CGRectGetMaxX(self.frame) - 10, y: CGFloat(yPos))
                
                let blockPhysicsBody = SKPhysicsBody(circleOfRadius: aBlock.size.width)
                blockPhysicsBody.affectedByGravity = false
                blockPhysicsBody.linearDamping = 1
                //                blockPhysicsBody.contactTestBitMask = 0x03
                //blockPhysicsBody.velocity = CGVector(dx: -800, dy: 0)
                blockPhysicsBody.allowsRotation = false
                aBlock.physicsBody = blockPhysicsBody
                
                let movementDistance : CGFloat = CGFloat(100.0)
                let moveBlock = SKAction.moveByX(-movementDistance, y: 0, duration: NSTimeInterval(0.01 * movementDistance))
                
                
                
                self.blocks.append(aBlock)
                self.scrollNode.addChild(aBlock)
                }
            ]
        )
    }
    
    func getRandomHeight() -> Float {
        let ARC4RANDOM_MAX : Float = 0x100000000
        return Float(arc4random()) / ARC4RANDOM_MAX
    }
    
    func killSparks() {
        sparks.removeFromParent()
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        faby.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        sparks.removeFromParent()
    }
    
    func setTitle() {
        startTitle.text = "Tap to begin!"
        startTitle.fontColor = UIColor.whiteColor()
        startTitle.fontSize = 35
        startTitle.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame))
        self.addChild(startTitle)
    }
}
