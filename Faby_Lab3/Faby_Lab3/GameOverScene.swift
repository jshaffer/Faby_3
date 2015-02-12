//
//  GameOverScene.swift
//  Faby_Lab3
//
//  Created by Classroom Tech User on 2/11/15.
//  Copyright (c) 2015 Joel Shaffer. All rights reserved.
//

import SpriteKit


class GameOverScene: SKScene {
    
    override func didMoveToView(view: SKView) {
        setTitle()
        setScores()
        showRestartLabel()
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        let trans = SKTransition.revealWithDirection(SKTransitionDirection.Down, duration: 0.5)
        let newGameScene = GameScene(fileNamed: "GameScene")
        newGameScene.scaleMode = SKSceneScaleMode.AspectFill
        
        view!.presentScene(newGameScene, transition: trans)
    }
    
    func setScores() {
        let lastScoreNode = SKLabelNode(fontNamed:"Chalkduster")
        let highScoreNode = SKLabelNode(fontNamed:"Chalkduster")
        
        if currentScore > highScore {
            highScore = currentScore
        }
        
        if highScore > theHighScoreManager.aScore.storedScore {
            theHighScoreManager.addNewScore(highScore)
        } else {
            highScore = theHighScoreManager.aScore.storedScore
        }
        
        highScoreNode.text = "High Score: \(highScore)"
        highScoreNode.fontColor = UIColor.whiteColor()
        highScoreNode.fontSize = 35
        highScoreNode.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame) - 40)
        
        lastScoreNode.text = "Score: \(currentScore)"
        lastScoreNode.fontColor = UIColor.whiteColor()
        lastScoreNode.fontSize = 35
        lastScoreNode.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame) - 80)
        
        self.addChild(highScoreNode)
        self.addChild(lastScoreNode)
    }
    
    func showRestartLabel() {
        let restartTitle = SKLabelNode(fontNamed:"Chalkduster")
        restartTitle.text = "Tap to restart"
        restartTitle.fontColor = UIColor.whiteColor()
        restartTitle.fontSize = 35
        restartTitle.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame) - 120)
        self.addChild(restartTitle)
    }
    
    func setTitle() {
        let startTitle = SKLabelNode(fontNamed:"Chalkduster")
        startTitle.text = "Game Over!"
        startTitle.fontColor = UIColor.whiteColor()
        startTitle.fontSize = 35
        startTitle.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame))
        self.addChild(startTitle)
    }
}