//
//  GameScene.swift
//  Faby_Lab3
//
//  Created by Joel Shaffer on 2/2/15.
//  Copyright (c) 2015 Joel Shaffer. All rights reserved.
//

import SpriteKit
import Darwin

var highScore: Int = 0
var currentScore: Int = 0

class GameScene: SKScene, SKPhysicsContactDelegate {
    var gameStatus = "start";
    let startTitle = SKLabelNode(fontNamed:"Chalkduster")
    let faby = SKSpriteNode(imageNamed:"angryBird")
    var soundEffect : SKAction!
    let sparks = SKEmitterNode(fileNamed: "fire")
    let scrollNode = SKNode()
    let groundNode = SKNode()
    let bottomBoundary = SKNode()
    let bk1 = SKSpriteNode(imageNamed: "angry_background")
    let bk2 = SKSpriteNode(imageNamed: "angry_background")
    let block = SKSpriteNode(imageNamed: "block_trans")
    var blocks : [SKSpriteNode] = []
    let scoreNode = SKLabelNode(fontNamed: "Chalkduster")
    
    
    let fabyMask : UInt32 = 0x00
    let wallMask : UInt32 = 0x01
    let blockMask : UInt32 = 0x02
    
    
    override func didMoveToView(view: SKView) {
        setupScreen(view)
        setTitle("Tap to begin!")
        setupPhysics()
        setupBackground()
        currentScore = 0
    }
    
    func setupPhysics() {
        physicsWorld.contactDelegate = self
        
        let height = frame.height / 40.0
        bottomBoundary.position = CGPointMake(0.0, height)
        bottomBoundary.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(self.frame.size.width, height * 2.0))
        bottomBoundary.physicsBody?.dynamic = false
        bottomBoundary.physicsBody?.categoryBitMask = wallMask
        
        self.addChild(bottomBoundary)
    }
    
    func setupScreen(view:SKView) {
        size = view.frame.size
        self.backgroundColor = UIColor.whiteColor()
    }
    
    func setupBackground() {
        bk1.anchorPoint = CGPointZero
        bk1.position = CGPointMake(0, 0)
        bk1.zPosition = -15
        groundNode.addChild(bk1)
        
        bk2.anchorPoint = CGPointZero
        bk2.position = CGPointMake(bk1.size.width - 1, 0)
        bk2.zPosition = -15
        groundNode.addChild(bk2)
        
        scrollNode.addChild(groundNode)
        
        self.addChild(scrollNode)
        backgroundImageHandler()
        
    }
    
    override func update(currentTime: NSTimeInterval) {
        if(gameStatus == "playing") {
            backgroundImageHandler()
        }
    }
    
    func backgroundImageHandler() {
        if gameStatus == "playing" {
            bk1.position = CGPointMake(bk1.position.x - 2, bk1.position.y)
            bk2.position = CGPointMake(bk2.position.x - 2, bk2.position.y)
            
            if(bk1.position.x < -bk1.size.width){
                bk1.position = CGPointMake(bk2.position.x + bk2.size.width, bk1.position.y)
            }
            
            if(bk2.position.x < -bk2.size.width) {
                bk2.position = CGPointMake(bk1.position.x + bk1.size.width, bk2.position.y)
            }
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
            setupBlocks()
            
            
            self.physicsWorld.gravity =  CGVector(dx: 0, dy: -15)
            self.addChild(faby)
        } else if(gameStatus == "playing") {
            if scrollNode.speed > 0 {
                
                //give upwards impulse
                faby.physicsBody?.velocity = CGVector(dx: 0, dy: 600)
                
                //add sound
                runAction(soundEffect)
                
                //add animation
                let addSparks = createSparks()
                runAction(addSparks)
                let timer = NSTimer.scheduledTimerWithTimeInterval(0.25, target: self, selector: Selector("killSparks"), userInfo: nil, repeats: false)
            }
        }
    }
    
    func addScoreNode(str: String) {
        scoreNode.removeFromParent()
        scoreNode.text = str
        scoreNode.fontSize = 15
        scoreNode.fontColor = UIColor.blackColor()
        scoreNode.position = CGPoint(x:CGRectGetMinX(self.frame) + 40, y:CGRectGetMaxY(self.frame) - 15)
        self.addChild(scoreNode)
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        faby.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        sparks.removeFromParent()
        
        if scrollNode.speed > 0 {
            let trans = SKTransition.revealWithDirection(SKTransitionDirection.Down, duration: 0.5)
            let gameOverScene = GameOverScene(fileNamed: "GameOverScene")
            gameOverScene.scaleMode = SKSceneScaleMode.AspectFill
            view!.presentScene(gameOverScene, transition: trans)
        }
    }
    
    func setupBlocks() {
        //add blocks
        let addBlocks = createBlock()
        let delay = SKAction.waitForDuration(0.75, withRange: 0.1)
        let incScore = incrementScore()
        let seq = SKAction.sequence([addBlocks, delay, incScore])
        let addBlocksForever = SKAction.repeatActionForever(seq)

        runAction(addBlocksForever, withKey: "addBlocksForever")
    }
    
    func createSparks() -> SKAction {
        return SKAction.sequence(
            [
                SKAction.runBlock {
                    self.sparks.removeFromParent()
                    self.sparks.position = CGPoint(x: self.faby.position.x - 10, y: self.faby.position.y + 20)
                    self.sparks.zPosition = 10
                    self.addChild(self.sparks)
                }
            ]
        )
    }
    
    func incrementScore() -> SKAction {
        return SKAction.sequence([SKAction.runBlock {
                currentScore = currentScore + 1
                self.addScoreNode("Score: \(currentScore)")
        }])
    }
    
    func createBlock() -> SKAction {
        return SKAction.sequence(
            [
                SKAction.runBlock {
                    let aBlock = SKSpriteNode(imageNamed: "block_trans")
                    let scaleFactor = self.getRandomScale()
                    aBlock.xScale = scaleFactor
                    aBlock.yScale = scaleFactor
                    let yPos = Float(CGRectGetMaxY(self.frame)) * self.getRandomHeight()
                    aBlock.position = CGPoint(x: CGRectGetMaxX(self.frame) - 10, y: CGFloat(yPos))
                    
                    let blockPhysicsBody = SKPhysicsBody(circleOfRadius: aBlock.size.width/2.0)
                    blockPhysicsBody.affectedByGravity = false
                    blockPhysicsBody.linearDamping = 1
                    
                    blockPhysicsBody.categoryBitMask = self.blockMask
                    blockPhysicsBody.contactTestBitMask = self.fabyMask
                    blockPhysicsBody.dynamic = false
                    blockPhysicsBody.allowsRotation = false
                    aBlock.physicsBody = blockPhysicsBody
                    
                    let movementDistance : CGFloat = CGFloat(1000.0)
                    let moveBlock = SKAction.moveByX(-movementDistance, y: 0, duration: NSTimeInterval(0.005 * movementDistance))
                    aBlock.runAction(moveBlock)
                    
                    
                    self.blocks.append(aBlock)
                    self.scrollNode.addChild(aBlock)
                }
            ]
        )
    }
    
    func getRandomScale() -> CGFloat {
        let val : Double = Double(arc4random_uniform(5) + 2)
        return CGFloat(val / 10.0)
    }
    
    func getRandomHeight() -> Float {
        let ARC4RANDOM_MAX : Float = 0x100000000
        return Float(arc4random()) / ARC4RANDOM_MAX
    }
    
    func killSparks() {
        sparks.removeFromParent()
    }
    
    func setTitle(str : String) {
        startTitle.text = str
        startTitle.fontColor = UIColor.whiteColor()
        startTitle.fontSize = 35
        startTitle.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame))
        self.addChild(startTitle)
    }
}

//***The below code was adapted from a tutorial available here:***
//http://www.thinkingswiftly.com/saving-spritekit-game-data-swift-easy-nscoder/

var theHighScoreManager = HighScoreManager()

class HighScore: NSObject, NSCoding {
    let storedScore:Int
    
    init(score:Int) {
        self.storedScore = score
    }
    
    required init(coder: NSCoder) {
        self.storedScore = coder.decodeObjectForKey("storedScore")! as Int
        super.init()
    }
    
    func encodeWithCoder(coder: NSCoder) {
        coder.encodeObject(self.storedScore, forKey: "storedScore")
    }
}

class HighScoreManager {
    var scores:Array<HighScore> = [];
    
    init() {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let documentsDirectory = paths[0] as String
        let path = documentsDirectory.stringByAppendingPathComponent("HighScores.plist")
        let fileManager = NSFileManager.defaultManager()
        
        if !fileManager.fileExistsAtPath(path) {
            if let bundle = NSBundle.mainBundle().pathForResource("DefaultFile", ofType: "plist") {
                fileManager.copyItemAtPath(bundle, toPath: path, error:nil)
            }
        }
        
        if let rawData = NSData(contentsOfFile: path) {
            var scoreArray: AnyObject? = NSKeyedUnarchiver.unarchiveObjectWithData(rawData);
            self.scores = scoreArray as? [HighScore] ?? [];
            
            for var i = 0; i < 5; i++ {
                self.scores.append(HighScore(score: 0))
            }
        }
    }
    
    func save() {
        let saveData = NSKeyedArchiver.archivedDataWithRootObject(self.scores);
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true) as NSArray;
        let documentsDirectory = paths.objectAtIndex(0) as NSString;
        let path = documentsDirectory.stringByAppendingPathComponent("HighScores.plist");
        
        saveData.writeToFile(path, atomically: true);
    }
    
    func addNewScore(newScore:Int) {
        let newHighScore = HighScore(score: newScore);
        var done = false
        for var i = 0; i < scores.count && !done; i++ {
            if newScore > scores[i].storedScore {
                self.scores.insert(newHighScore, atIndex: i)
                self.scores.removeLast()
                done = true
            }
        }
        
        //clearScores is only implemented for testing purposes, and allows me to clear all the scores
        //clearScores();
        
        self.save();
    }
    
    func clearScores() {
        scores.removeAll(keepCapacity: false)
        for var i = 0; i < 5; i++ {
            scores.append(HighScore(score: 0))
        }
    }
}






