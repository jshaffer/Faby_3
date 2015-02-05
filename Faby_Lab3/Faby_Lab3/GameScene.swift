//
//  GameScene.swift
//  Faby_Lab3
//
//  Created by Joel Shaffer on 2/2/15.
//  Copyright (c) 2015 Joel Shaffer. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    var gameStatus = "start";
    let startTitle = SKLabelNode(fontNamed:"Chalkduster")
    let faby = SKSpriteNode(imageNamed:"angryBird")
    var soundEffect : SKAction!
    let sparks = SKEmitterNode(fileNamed: "fire")
    let bk1 = SKSpriteNode(imageNamed: "angry_background")
    let bk2 = SKSpriteNode(imageNamed: "angry_background")
    let block = SKSpriteNode(imageNamed: "block_trans")
    
    
    
    override func didMoveToView(view: SKView) {
        size = view.frame.size
        
        self.backgroundColor = UIColor.whiteColor()
        
        setTitle()
        self.addChild(startTitle)
        
        physicsWorld.contactDelegate = self
        self.physicsBody = SKPhysicsBody(edgeLoopFromRect: self.frame)
        
        bk1.anchorPoint = CGPointZero
        bk1.position = CGPointMake(0, 0)
        bk1.zPosition = -15
        self.addChild(bk1)
        
        bk2.anchorPoint = CGPointZero
        bk2.position = CGPointMake(bk1.size.width - 1, 0)
        bk2.zPosition = -15
        self.addChild(bk2)
        
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
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        if(gameStatus == "start") {
            startTitle.removeFromParent()
            gameStatus =  "playing"
            
            faby.xScale = 0.25
            faby.yScale = 0.25
            faby.zPosition = 5
            faby.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMaxY(self.frame) * 0.7)
            
            //give faby some physics
            let physicsBody = SKPhysicsBody(circleOfRadius: faby.size.height/2.0)
            physicsBody.affectedByGravity = true
            physicsBody.linearDamping = 0
            physicsBody.contactTestBitMask = 0x01
            faby.physicsBody = physicsBody
            
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
            let addSparks = SKAction.sequence([SKAction.runBlock {
                self.sparks.removeFromParent()
                self.sparks.position = CGPoint(x: self.faby.position.x - 10, y: self.faby.position.y + 20)
                self.sparks.zPosition = 10
                self.addChild(self.sparks)
                }
            ])
            
            runAction(addSparks)
            let timer = NSTimer.scheduledTimerWithTimeInterval(0.25, target: self, selector: Selector("killSparks"), userInfo: nil, repeats: false)
            
            
            //add blocks
            let addBlocks = SKAction.sequence([SKAction.runBlock {
                self.block.removeFromParent()
                self.block.xScale = 0.5
                self.block.yScale = 0.5
                self.block.position = CGPoint(x: CGRectGetMaxX(self.frame) - 10, y: CGRectGetMaxY(self.frame) - 10)
                
                    self.addChild(self.block)
                }
            ])
            runAction(addBlocks)
            
        }
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
    }
}
