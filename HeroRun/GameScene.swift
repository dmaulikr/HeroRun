//
//  GameScene.swift
//  HeroRun
//
//  Created by Manh Do on 4/4/16.
//  Copyright (c) 2016 DoGames. All rights reserved.
//


import SpriteKit

class GameScene: SKScene {
    
    var myLabel: SKLabelNode!
    var playButton: SKSpriteNode!
    
    override func didMoveToView(view: SKView) {
        
        self.backgroundColor = UIColor.blackColor()
        
        /* Setup your scene here */
        myLabel = SKLabelNode(fontNamed:"Chalkduster")
        myLabel.text = "HERO RUN"
        myLabel.fontSize = 75
        myLabel.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame))
        
        self.addChild(myLabel)
        
       

        
        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        /* Called when a touch begins */
        
        let transition = SKTransition.fadeWithDuration(1.0)
        //let transition = SKTransition.revealWithDirection(.Down, duration: 0.5)
        let nextScene = GameplayScene(size: scene!.size)
        nextScene.scaleMode = .AspectFill
        
        scene?.view?.presentScene(nextScene, transition: transition)
        
        
     
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}








