//
//  GameOverScene.swift
//  HeroRun
//
//  Created by Manh Do on 4/16/16.
//  Copyright © 2016 DoGames. All rights reserved.
//

import SpriteKit

class GameOverScene: SKScene {
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        self.backgroundColor = UIColor.blackColor()
        let myLabel = SKLabelNode(fontNamed:"Chalkduster")
        myLabel.text = "GAME OVER"
        myLabel.fontSize = 60
        myLabel.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame))
        
        self.addChild(myLabel)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        /* Called when a touch begins */
        
        let transition = SKTransition.fadeWithDuration(1.0)
       // let transition = SKTransition.revealWithDirection(.Down, duration: 0.5)
        let nextScene = GameScene(size: scene!.size)
        nextScene.scaleMode = .AspectFill
        
        scene?.view?.presentScene(nextScene, transition: transition)
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}



