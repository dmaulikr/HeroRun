//
//  GameplayScene.swift
//  HeroRun
//
//  Created by Manh Do on 4/15/16.
//  Copyright © 2016 DoGames. All rights reserved.
//

import SpriteKit
import AVFoundation

class GameplayScene: SKScene, SKPhysicsContactDelegate {
    
    //Game Condition
    var isGameOver: Bool!
    var isGameWin: Bool!
    
    // Background
    var background: SKNode!
    let background_speed = 250.0
    var backgroundMusicPlayer = AVAudioPlayer()
    
    // Mage
    var mage: SKSpriteNode!
    let mageAtlas = SKTextureAtlas(named: "Mage.atlas")
    var mageRunSprites = Array<SKTexture>()
    var mageAttackSprites = Array<SKTexture>()
    var mageJumpingSprites = Array<SKTexture>()
    var isJumping: Bool!
    
    // Fireball
    let fireballAtlas = SKTextureAtlas(named: "Fireball.atlas")
    var fireballSprite = Array<SKTexture>()
    var fireballParticalsSprite = Array<SKTexture>()
    
    // health and mana
    var manaHUD: SKSpriteNode!
    var pauseButton: SKSpriteNode!
    var playButton: SKSpriteNode!
    var manaLabel: SKLabelNode!
    var mana: Int!
    
    // Skeleton
    let skeletonAtlas = SKTextureAtlas(named: "Skeleton.atlas")
    var skeletonSprite = Array<SKTexture>()
    
    // Bat
    let batAtlas = SKTextureAtlas(named: "Bat.atlas")
    var batSprite = Array<SKTexture>()
    
    // Demon
    let demonAtlas = SKTextureAtlas(named: "Demon.atlas")
    var demonLeftSprite = Array<SKTexture>()
    var demonRightSprite = Array<SKTexture>()
    var isDemonRight: Bool!
    var canHitDemon: Bool!
    var demonCount: Int!
    
    // Boss
    var boss: SKSpriteNode!
    let bossAtlas = SKTextureAtlas(named: "Boss.atlas")
    var bossAttackSprites = Array<SKTexture>()
    var bossHP: Int!

    // Boss Fireball
    let bFireballAtlas = SKTextureAtlas(named: "BFireball.atlas")
    var bFireballSprite = Array<SKTexture>()
    
    // DeathSprite
    let deathAtlas = SKTextureAtlas(named: "Death.atlas")
    var deathSprite = Array<SKTexture>()
    
    // Time Values
    var delta = NSTimeInterval(0)
    var last_update_time = NSTimeInterval(0)
    
    // Floor
    let floor_distance: CGFloat = 150
    var leftWall: SKSpriteNode!
    
    // Physics Categories
    let boundaryCategory:  UInt32 = 1 << 0
    let playerCategory:    UInt32 = 1 << 1
    let fireballCategory:  UInt32 = 1 << 2
    let enemyCategory:     UInt32 = 1 << 3
    let demonCategory:     UInt32 = 1 << 4
    let leftWallCategory:  UInt32 = 1 << 5
    let bossCategory:      UInt32 = 1 << 6
    let bFireballCategory: UInt32 = 1 << 7
    let playButtonCategory: UInt32 = 1 << 8
    
    override func didMoveToView(view: SKView) {
        isGameOver = false
        isGameWin = false
        
        mana = 5
        demonCount = 0
        
        initSprites()
        initHUD()
        initMana()
        regenMana()
        initWorld()
        initBackground()
        initMage()
        
        spawnSkeleton()
        spawnSkeleton2()
        spawnBat()
        spawnDemon()
        
        //initSkeleton()
        //initBat()
        //initDemon()
        //initBoss()
        
        playBackgroundMusic("level1.mp3")
    }
    
    // touch screen
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch: AnyObject in touches {
            let location = touch.locationInNode(self)
            
            // Resume the scene
            if playButton.containsPoint(location) {
                self.scene!.view!.paused = false
                backgroundMusicPlayer.play()
            }
            
            // Pausing the scene
            if pauseButton.containsPoint(location) {
                self.scene!.view!.paused = true
                backgroundMusicPlayer.stop()
            }
            
             // left side of the screen
            if location.x < self.frame.size.width / 2 &&
            location.y < self.frame.size.height - 200{
                mageJump()
            }
            
            // right side of the screen
            if location.x > self.frame.size.width / 2 &&
            location.y < self.frame.size.height - 200{
                if mana > 0 {
                    mana = mana - 1
                    fireballAtk()
                }
                else {
                    print("NO MANA")
                }
            }
        }
    }
    
    // Update
    override func update(currentTime: CFTimeInterval) {
        delta = (last_update_time == 0.0) ? 0.0 : currentTime - last_update_time
        last_update_time = currentTime
        
        manaLabel.removeFromParent()
        initMana()
        
        moveBackground()
        
        if (isGameOver == true) {
            gameOver()
        }
        if (isGameWin == true) {
            gameWin()
        }
        
    
    }
    
    
    
    // GAME CONDITIONS /////////////////////
    func gameOver() {
        backgroundMusicPlayer.stop()
        let transition = SKTransition.crossFadeWithDuration(1.0)
        let nextScene = GameOverScene(size: scene!.size)
        nextScene.scaleMode = .AspectFill
        
        scene?.view?.presentScene(nextScene, transition: transition)
    }
    
    func gameWin() {
        backgroundMusicPlayer.stop()
        let transition = SKTransition.crossFadeWithDuration(1.0)
        let nextScene = GameWinScene(size: scene!.size)
        nextScene.scaleMode = .AspectFill
        
        scene?.view?.presentScene(nextScene, transition: transition)
    }
    
    
    
    // Background music ///////////////////////
    func playBackgroundMusic(filename: String) {
        let url = NSBundle.mainBundle().URLForResource(filename, withExtension: nil)
        guard let newURL = url else {
            print("Could not find file: \(filename)")
            return
        }
        do {
            backgroundMusicPlayer = try AVAudioPlayer(contentsOfURL: newURL)
            backgroundMusicPlayer.numberOfLoops = -1
            backgroundMusicPlayer.prepareToPlay()
            backgroundMusicPlayer.play()
        } catch let error as NSError {
            print(error.description)
        }
    }

    
    
    // INITIALIZE ALL SPRITES //////////////////
    func initSprites() {
        mageRunSprites.append(mageAtlas.textureNamed("Mage1"))
        mageRunSprites.append(mageAtlas.textureNamed("Mage2"))
        mageRunSprites.append(mageAtlas.textureNamed("Mage3"))
        mageRunSprites.append(mageAtlas.textureNamed("Mage4"))
        mageRunSprites.append(mageAtlas.textureNamed("Mage5"))
        mageRunSprites.append(mageAtlas.textureNamed("Mage6"))
        
        mageAttackSprites.append(mageAtlas.textureNamed("MageDeath"))
        mageAttackSprites.append(mageAtlas.textureNamed("MageAttack"))
        
        mageJumpingSprites.append(mageAtlas.textureNamed("Mage6"))
        mageJumpingSprites.append(mageAtlas.textureNamed("Mage4"))
        
        fireballSprite.append(fireballAtlas.textureNamed("Fireball1"))
        fireballSprite.append(fireballAtlas.textureNamed("Fireball2"))
        fireballSprite.append(fireballAtlas.textureNamed("Fireball3"))
        fireballSprite.append(fireballAtlas.textureNamed("Fireball4"))
        
        fireballParticalsSprite.append(fireballAtlas.textureNamed("FireballParticals1"))
        fireballParticalsSprite.append(fireballAtlas.textureNamed("FireballParticals2"))
        fireballParticalsSprite.append(fireballAtlas.textureNamed("FireballParticals3"))
        
        bossAttackSprites.append(bossAtlas.textureNamed("BossAttack"))
        bossAttackSprites.append(bossAtlas.textureNamed("Boss"))
        
        bFireballSprite.append(bFireballAtlas.textureNamed("Fireball1"))
        bFireballSprite.append(bFireballAtlas.textureNamed("Fireball2"))
        bFireballSprite.append(bFireballAtlas.textureNamed("Fireball3"))
        bFireballSprite.append(bFireballAtlas.textureNamed("Fireball4"))
        
        skeletonSprite.append(skeletonAtlas.textureNamed("Skeleton1"))
        skeletonSprite.append(skeletonAtlas.textureNamed("Skeleton2"))
        skeletonSprite.append(skeletonAtlas.textureNamed("Skeleton3"))
        skeletonSprite.append(skeletonAtlas.textureNamed("Skeleton4"))
        skeletonSprite.append(skeletonAtlas.textureNamed("Skeleton5"))
        skeletonSprite.append(skeletonAtlas.textureNamed("Skeleton6"))
        
        batSprite.append(batAtlas.textureNamed("Bat1"))
        batSprite.append(batAtlas.textureNamed("Bat2"))
        batSprite.append(batAtlas.textureNamed("Bat3"))
        
        deathSprite.append(deathAtlas.textureNamed("Death1"))
        deathSprite.append(deathAtlas.textureNamed("Death2"))
        deathSprite.append(deathAtlas.textureNamed("Death3"))
        deathSprite.append(deathAtlas.textureNamed("Death4"))
        deathSprite.append(deathAtlas.textureNamed("Death5"))
        
        demonLeftSprite.append(demonAtlas.textureNamed("DemonL1"))
        demonLeftSprite.append(demonAtlas.textureNamed("DemonL2"))
        demonLeftSprite.append(demonAtlas.textureNamed("DemonL3"))
        demonLeftSprite.append(demonAtlas.textureNamed("DemonL4"))
        demonLeftSprite.append(demonAtlas.textureNamed("DemonL5"))
        demonLeftSprite.append(demonAtlas.textureNamed("DemonL6"))
        
        demonRightSprite.append(demonAtlas.textureNamed("DemonR1"))
        demonRightSprite.append(demonAtlas.textureNamed("DemonR2"))
        demonRightSprite.append(demonAtlas.textureNamed("DemonR3"))
        demonRightSprite.append(demonAtlas.textureNamed("DemonR4"))
        demonRightSprite.append(demonAtlas.textureNamed("DemonR5"))
        demonRightSprite.append(demonAtlas.textureNamed("DemonR6"))
    }
    
    
    
    // WORLD ///////////////////////////
    func initWorld() {
        physicsWorld.contactDelegate = self
        
        // Set the gravity force, in this case its -5.0
        physicsWorld.gravity = CGVector(dx: 0.0, dy: -8.5)
        
        // Set the frame of the phusics body that wil act as our boundary
        physicsBody = SKPhysicsBody(
            edgeLoopFromRect: CGRect(x: 0.0,
                y: floor_distance,
                width: size.width + 200,
                height: size.height - floor_distance))
        
        // Set the Physics Category that will identify this body and set the Physics Category
        // that can collide with it
        physicsBody?.categoryBitMask = boundaryCategory
        physicsBody?.contactTestBitMask = bossCategory
        physicsBody?.collisionBitMask = playerCategory
        physicsBody?.restitution = 0.0
        
        leftWall = SKSpriteNode()
        leftWall.position = CGPoint(x: 1, y: 400)
        leftWall.zPosition = 10
        
        leftWall.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: 1, height: frame.height/2))
        leftWall.physicsBody?.categoryBitMask = leftWallCategory
        leftWall.physicsBody?.contactTestBitMask = demonCategory | enemyCategory
        leftWall.physicsBody?.collisionBitMask = boundaryCategory
        leftWall.physicsBody?.allowsRotation = false
        leftWall.physicsBody?.restitution = 0.0
        
        addChild(leftWall)
    }
    
    
    
    
    // BACKGROUND ////////////////////////
    func initBackground() {
        background = SKNode()
        
        addChild(background)
        
        self.backgroundColor = SKColor.grayColor()
        
        // create 2 tiles and add them to our background node, this will help you create
        // an infinte scroll effect
        for i in 0...2 {
            let tile = SKSpriteNode(imageNamed: "bg")
            tile.anchorPoint = CGPointZero
            tile.position = CGPoint(x: CGFloat(i) * 640.0, y: 105.0)
            tile.name = "bg"
            tile.zPosition = 1
            background.addChild(tile)
        }
    }
    
    func moveBackground() {
        let posX = -background_speed * delta
        background.position = CGPoint(x: background.position.x + CGFloat(posX), y: 0.0)
        
        background.enumerateChildNodesWithName("bg") {
            (node, stop) in
            let background_screen_position = self.background.convertPoint(node.position, toNode: self)
            
            if background_screen_position.x <= -node.frame.size.width {
                node.position = CGPoint(x: node.position.x + (node.frame.size.width * 3), y: node.position.y)
            }
        }
    }

    
    
    
    // HUD /////////////////////////////////
    func initHUD() {
        // Pause Button
        pauseButton = SKSpriteNode(imageNamed: "PauseButton")
        pauseButton.size = CGSize(width: 80, height: 80)
        pauseButton.position = CGPoint(x: frame.width - 100 , y: frame.height - 150)
        pauseButton.zPosition = 10
        
        addChild(pauseButton)
        
        // Resume Button
        playButton = SKSpriteNode(imageNamed: "PlayButton")
        playButton.size = CGSize(width: 80, height: 80)
        playButton.position = CGPoint(x: frame.width - 200 , y: frame.height - 150)
        playButton.zPosition = 10

        addChild(playButton)
        
        playButton.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: 100, height: 300))
        playButton.physicsBody?.categoryBitMask = playButtonCategory
        playButton.physicsBody?.contactTestBitMask = bossCategory
        playButton.physicsBody?.affectedByGravity = false
        playButton.physicsBody?.allowsRotation = false
        playButton.physicsBody?.restitution = 0.0
        
        // mana HUD
        manaHUD = SKSpriteNode(imageNamed: "manaHUD")
        manaHUD.size = CGSize(width: 240, height: 80)
        manaHUD.position = CGPoint(x: 120, y: frame.height - 150)
        manaHUD.zPosition = 10
        
        addChild(manaHUD)
    }
    
    func initMana() {
        manaLabel = SKLabelNode(fontNamed:"Chalkduster")
        manaLabel.text = "\(mana)/5"
        manaLabel.fontSize = 50
        manaLabel.position = CGPoint(x: 140, y: frame.height - 165)
        manaLabel.zPosition = 11
        self.addChild(manaLabel)
    }

    func regenMana() {
        let wait = SKAction.waitForDuration(1.3)
        let increaseMana = SKAction.runBlock { self.increaseMana() }
        
        let sequence = SKAction.sequence([wait, increaseMana])
        self.runAction(SKAction.repeatActionForever(sequence))
    }
    
    func increaseMana() {
        if(mana < 5) {
            mana = mana + 1
        }
    }

    
    
    // HERO //////////////////////////////
    func initMage() {
        mage = SKSpriteNode()
        mage.size = CGSize(width: 75, height: 75)
        mage.position = CGPoint(x: 300, y: 200)
        mage.zPosition = 5
        
        isJumping = false
        
        mage.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: 55, height:75))
        mage.physicsBody?.categoryBitMask = playerCategory
        mage.physicsBody?.contactTestBitMask = enemyCategory | demonCategory
        mage.physicsBody?.collisionBitMask = boundaryCategory
        mage.physicsBody?.allowsRotation = false
        mage.physicsBody?.restitution = 0.0
        
        mageRunAnimation()
        addChild(mage)
    }
    
    func mageRunAnimation() {
        let animatedMage = SKAction.animateWithTextures(mageRunSprites, timePerFrame: 0.1)
        let action = SKAction.repeatActionForever(animatedMage)
        mage.runAction(action)
    }
    
    func mageAtkAnimation() {
        let animatedMage = SKAction.animateWithTextures(mageAttackSprites, timePerFrame: 0.15)
        let action = SKAction.repeatAction(animatedMage, count: 1)
        mage.runAction(action)
    }
    
    func mageJumpAnimation() {
        let animatedMage = SKAction.animateWithTextures(mageJumpingSprites, timePerFrame: 0.63)
        let action = SKAction.repeatAction(animatedMage, count: 1)
        mage.runAction(action)
    }
    
    func mageJump() {
        
        // check to see if mage y position is <= floor_distance
        // added 10 because some decimals were cut off
        if (mage.position.y - mage.size.height / 2 <= floor_distance + 10) {
            isJumping = false
        }
        
        if(isJumping == true) {
        }
        else {
            mageJumpAnimation()
            mage.physicsBody?.applyImpulse(CGVectorMake(0, 150))
            isJumping = true
            runAction(SKAction.playSoundFileNamed("playerjump.mp3", waitForCompletion: true))
        }
    }

    
    
    // HERO FIREBALL ////////////////////////
    func fireballAtk() {
        
        let fireball = SKSpriteNode()
        fireball.size = CGSize(width: 35, height: 35)
        fireball.position = CGPoint(x: mage.position.x + 50, y: mage.position.y)
        fireball.zPosition = 6
        
        fireball.physicsBody = SKPhysicsBody(circleOfRadius: 15)
        fireball.physicsBody?.categoryBitMask = fireballCategory
        fireball.physicsBody?.contactTestBitMask = enemyCategory | demonCategory | bFireballCategory | bossCategory
        fireball.physicsBody?.collisionBitMask = boundaryCategory
        fireball.physicsBody?.affectedByGravity = false
        fireball.physicsBody?.allowsRotation = false
        fireball.physicsBody?.restitution = 0.0
        fireball.physicsBody?.usesPreciseCollisionDetection = true
        
        // nodes are automatically remove when it leave the scene
        // thus purposly increase the moveToX by 100 to leave the scene
        let action = SKAction.moveToX(frame.width + 100, duration: 2)
        let actionDone = SKAction.removeFromParent()
        fireball.runAction(SKAction.sequence([action, actionDone]))
        
        let animatedFireball = SKAction.animateWithTextures(fireballSprite, timePerFrame: 0.1)
        let repeatAction  = SKAction.repeatActionForever(animatedFireball)
        fireball.runAction(repeatAction)
        
        addChild(fireball)
        
        mageAtkAnimation()
    }
    
    func fireballParticalsAnimation(fireball: SKSpriteNode) {
        fireball.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: 0, height: 0))
        fireball.removeAllActions()
        let action = SKAction.animateWithTextures(fireballParticalsSprite, timePerFrame: 0.1)
        let actionDone = SKAction.removeFromParent()
        fireball.runAction(SKAction.sequence([action, actionDone]))
    }

    
    
    
    // SKELETON ////////////////////////
    func initSkeleton() {
        let skeleton = SKSpriteNode()
        skeleton.size = CGSize(width: 75, height:75)
        skeleton.position = CGPoint(x: frame.width, y: 250)
        skeleton.zPosition = 3
        skeleton.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: 60, height:70))
        skeleton.physicsBody?.categoryBitMask = enemyCategory
        skeleton.physicsBody?.contactTestBitMask = playerCategory | fireballCategory | leftWallCategory
        skeleton.physicsBody?.collisionBitMask = boundaryCategory
        skeleton.physicsBody?.allowsRotation = false
        skeleton.physicsBody?.restitution = 0.0
        
        let action = SKAction.moveToX(-200, duration: 5)
        let actionDone = SKAction.removeFromParent()
        skeleton.runAction(SKAction.sequence([action, actionDone]))
        
        let animatedSkeleton = SKAction.animateWithTextures(skeletonSprite, timePerFrame: 0.1)
        let repeatAction  = SKAction.repeatActionForever(animatedSkeleton)
        skeleton.runAction(repeatAction)
        
        addChild(skeleton)
    }
    
    func spawnSkeleton() {
        let wait = SKAction.waitForDuration(2, withRange: 1)
        let spawn = SKAction.runBlock { self.initSkeleton() }
        
        let sequence = SKAction.sequence([wait, spawn])
        self.runAction(SKAction.repeatActionForever(sequence), withKey: "spawnSkeleton1")
    }
    
    func spawnSkeleton2() {
        let wait = SKAction.waitForDuration(4, withRange: 1)
        let spawn = SKAction.runBlock { self.initSkeleton() }
        
        let sequence = SKAction.sequence([wait, spawn])
        self.runAction(SKAction.repeatActionForever(sequence), withKey: "spawnSkeleton2")
    }
    
    
    
    // BAT ////////////////////////////
    func initBat() {
        let bat = SKSpriteNode()
        bat.size = CGSize(width: 50, height: 50)
        bat.position = CGPoint(x: frame.width, y: frame.height - 350)
        bat.zPosition = 3
        
        bat.physicsBody = SKPhysicsBody(circleOfRadius: 25)
        bat.physicsBody?.categoryBitMask = enemyCategory
        bat.physicsBody?.contactTestBitMask = playerCategory | fireballCategory
        bat.physicsBody?.collisionBitMask = boundaryCategory
        bat.physicsBody?.affectedByGravity = false
        bat.physicsBody?.allowsRotation = false
        bat.physicsBody?.restitution = 0.0
        
        let action = SKAction.moveTo(CGPoint(x: mage.position.x, y: mage.position.y) , duration: 9)
        let action2 = SKAction.moveToX(0, duration: 3)
        
        let actionDone = SKAction.removeFromParent()
        bat.runAction(SKAction.sequence([action, action2, actionDone]))
        
        let animatedBat = SKAction.animateWithTextures(batSprite, timePerFrame: 0.1)
        let repeatAction = SKAction.repeatActionForever(animatedBat)
        bat.runAction(repeatAction)
        
        addChild(bat)
    }
    
    func spawnBat() {
        let wait = SKAction.waitForDuration(6, withRange: 2)
        let spawn = SKAction.runBlock { self.initBat() }
        
        let sequence = SKAction.sequence([wait, spawn])
        self.runAction(SKAction.repeatActionForever(sequence), withKey: "spawnBat")
    }
    
    
    
    // DEMON ///////////////////////////
    func initDemon() {
        let demon = SKSpriteNode()
        demon.size = CGSize(width: 75, height: 75)
        demon.position = CGPoint(x: frame.width, y: 250)
        demon.zPosition = 3
        
        isDemonRight = false
        canHitDemon = false
        
        demon.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: 60, height:75))
        demon.physicsBody?.categoryBitMask = demonCategory
        demon.physicsBody?.contactTestBitMask = leftWallCategory | fireballCategory
        demon.physicsBody?.collisionBitMask = boundaryCategory
        demon.physicsBody?.allowsRotation = false
        demon.physicsBody?.restitution = 0.0
        
        let action = SKAction.moveToX(0, duration: 6)
        demon.runAction(action)
        
        let animatedDemonLeft = SKAction.animateWithTextures(demonLeftSprite, timePerFrame: 0.1)
        let repeatAction  = SKAction.repeatActionForever(animatedDemonLeft)
        demon.runAction(repeatAction)
        
        addChild(demon)
    }
    
    func demonMoveRight(demon: SKSpriteNode) {
        demon.removeAllActions()
        
        canHitDemon = true
        
        let animateAction = SKAction.animateWithTextures(demonRightSprite, timePerFrame: 0.1)
        let repeatAnimateAction = SKAction.repeatActionForever(animateAction)
        let moveAction = SKAction.moveToX(frame.width + 100, duration: 6)
        
        demon.runAction(repeatAnimateAction)
        demon.runAction(moveAction)
    }
    
    func spawnDemon() {
        let wait = SKAction.waitForDuration(12)
        let spawn = SKAction.runBlock { self.initDemon() }
        
        let sequence = SKAction.sequence([wait, spawn])
        self.runAction(SKAction.repeatActionForever(sequence), withKey: "spawnDemon")
    }
    
    
    
    // BOSS //////////////////////////////////////
    func initBoss() {
        boss = SKSpriteNode(texture: bossAtlas.textureNamed("Boss"))
        boss.size = CGSize(width: 250, height: 100)
        boss.position = CGPoint(x: frame.width - 150, y: frame.height - 400)
        boss.zPosition = 5
        
        bossHP = 8
        
        boss.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: 100, height: 100))
        boss.physicsBody?.categoryBitMask = bossCategory
        boss.physicsBody?.contactTestBitMask = fireballCategory | playButtonCategory | boundaryCategory
        boss.physicsBody?.allowsRotation = false
        boss.physicsBody?.restitution = 0
        boss.physicsBody?.affectedByGravity = false
        
        bossMoveDown()
        bossAttack()
        
        addChild(boss)
    }
    
    func bossMoveDown() {
        let action = SKAction.moveToY(0, duration: 2)
        boss.runAction(action)
    }
    
    func bossMoveUp() {
        let action = SKAction.moveToY(frame.height, duration: 2)
        boss.runAction(action)
    }
    
    func bossAttack() {
        let wait = SKAction.waitForDuration(2, withRange: 1)
        let spawn = SKAction.runBlock { self.initBFireball() }
        let sequence = SKAction.sequence([wait, spawn])
        self.runAction(SKAction.repeatActionForever(sequence))
    }
    
    func BossAtkAnimation() {
        let animatedBoss = SKAction.animateWithTextures(bossAttackSprites, timePerFrame: 0.2)
        let action = SKAction.repeatAction(animatedBoss, count: 1)
        boss.runAction(action)
    }
    
    func spawnBoss() {
        self.removeActionForKey("spawnSkeleton1")
        self.removeActionForKey("spawnSkeleton2")
        self.removeActionForKey("spawnBat")
        self.removeActionForKey("spawnDemon")
        
        let wait = SKAction.waitForDuration(5)
        let spawn = SKAction.runBlock { self.initBoss() }
        
        let sequence = SKAction.sequence([wait, spawn])
        self.runAction(sequence)
    }


    
    // BOSS Fireball ////////////////////////////
    func initBFireball() {
        let bFireball = SKSpriteNode()
        bFireball.size = CGSize(width: 50, height: 50)
        bFireball.position = CGPoint(x: boss.position.x - 100, y: boss.position.y)
        bFireball.zPosition = 6
        
        bFireball.physicsBody = SKPhysicsBody(circleOfRadius: 20)
        bFireball.physicsBody?.categoryBitMask = bFireballCategory
        bFireball.physicsBody?.contactTestBitMask = playerCategory | fireballCategory
        bFireball.physicsBody?.collisionBitMask = boundaryCategory
        bFireball.physicsBody?.affectedByGravity = false
        bFireball.physicsBody?.allowsRotation = false
        bFireball.physicsBody?.restitution = 0.0
        bFireball.physicsBody?.usesPreciseCollisionDetection = true
        
        let action = SKAction.moveTo(CGPoint(x: mage.position.x - 50, y: mage.position.y) , duration: 2)
        let action2 = SKAction.moveToX(0, duration: 1)
        let actionDone = SKAction.removeFromParent()
        bFireball.runAction(SKAction.sequence([action, action2, actionDone]))
        
        let animatedBFireball = SKAction.animateWithTextures(bFireballSprite, timePerFrame: 0.1)
        let repeatAction  = SKAction.repeatActionForever(animatedBFireball)
        bFireball.runAction(repeatAction)
        
        addChild(bFireball)
        
        BossAtkAnimation()
        
    }
 

    
    // Death animation
    func deathAnimation(entity: SKSpriteNode) {
        entity.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: 0, height: 0))
        entity.removeAllActions()
        let action = SKAction.animateWithTextures(deathSprite, timePerFrame: 0.1)
        let actionDone = SKAction.removeFromParent()
        entity.runAction(SKAction.sequence([action, actionDone]))
    }
    
    
    
    // COLLISION DETECTIONS ///////////////////////
    func didBeginContact(contact: SKPhysicsContact) {
        let firstBody: SKPhysicsBody = contact.bodyA
        let secondBody: SKPhysicsBody = contact.bodyB
        
        if firstBody.node == nil || secondBody.node == nil {
            print("NIL was found")
            return
        }
        
        // Collision with fireball and enemy
        if ((firstBody.categoryBitMask == fireballCategory) &&
            (secondBody.categoryBitMask == enemyCategory)) {
            
            collisionFireballWithEnemy(firstBody.node as! SKSpriteNode, enemy: secondBody.node as! SKSpriteNode)
            
        }
        if ((firstBody.categoryBitMask == enemyCategory) &&
            (secondBody.categoryBitMask == fireballCategory)) {
            
            collisionFireballWithEnemy(secondBody.node as! SKSpriteNode, enemy: firstBody.node as! SKSpriteNode)
        }
        
        // collision with mage and enemy
        if ((firstBody.categoryBitMask == playerCategory) &&
            (secondBody.categoryBitMask == enemyCategory)) ||
            ((firstBody.categoryBitMask == enemyCategory) &&
                (secondBody.categoryBitMask == playerCategory)) {
            runAction(SKAction.playSoundFileNamed("playerhit.mp3", waitForCompletion: true))
            isGameOver = true
        }
        
        // collision with mage and demon
        if ((firstBody.categoryBitMask == playerCategory) &&
            (secondBody.categoryBitMask == demonCategory)) ||
            ((firstBody.categoryBitMask == demonCategory) &&
                (secondBody.categoryBitMask == playerCategory)) {
            runAction(SKAction.playSoundFileNamed("playerhit.mp3", waitForCompletion: true))
            isGameOver = true
        }
        
        // collision with demon leftwall
        if ((firstBody.categoryBitMask == leftWallCategory) &&
            (secondBody.categoryBitMask == demonCategory)) {
            
            demonMoveRight(secondBody.node as! SKSpriteNode)
        }
        if ((firstBody.categoryBitMask == demonCategory) &&
            (secondBody.categoryBitMask == leftWallCategory)) {
            
            demonMoveRight(firstBody.node as! SKSpriteNode)
        }
        
        // Collision with fireball and demon
        if ((firstBody.categoryBitMask == fireballCategory) &&
            (secondBody.categoryBitMask == demonCategory)  &&
            (canHitDemon == true)) {
            
            collisionFireballWithDemon(firstBody.node as! SKSpriteNode, demon: secondBody.node as! SKSpriteNode)
        }
        if ((firstBody.categoryBitMask == demonCategory) &&
            (secondBody.categoryBitMask == fireballCategory) &&
            (canHitDemon == true)) {

            collisionFireballWithDemon(secondBody.node as! SKSpriteNode, demon: firstBody.node as! SKSpriteNode)
        }
        if ((firstBody.categoryBitMask == fireballCategory) &&
            (secondBody.categoryBitMask == demonCategory)  &&
            (canHitDemon == false)) {
            
            runAction(SKAction.playSoundFileNamed("playerhit.mp3", waitForCompletion: true))
            fireballParticalsAnimation(firstBody.node as! SKSpriteNode)
        }
        if ((firstBody.categoryBitMask == demonCategory) &&
            (secondBody.categoryBitMask == fireballCategory) &&
            (canHitDemon == false)) {
            
            runAction(SKAction.playSoundFileNamed("playerhit.mp3", waitForCompletion: true))
            fireballParticalsAnimation(secondBody.node as! SKSpriteNode)
            
        }
        
        // collision with enemies with leftWall
        if ((firstBody.categoryBitMask == leftWallCategory) &&
            (secondBody.categoryBitMask == enemyCategory)) {
            
            collisionLeftWallWithEnemy(firstBody.node as! SKSpriteNode, enemy: secondBody.node as! SKSpriteNode)
            
        }
        if ((firstBody.categoryBitMask == enemyCategory) &&
            (secondBody.categoryBitMask == leftWallCategory)) {
            
            collisionLeftWallWithEnemy(secondBody.node as! SKSpriteNode, enemy: firstBody.node as! SKSpriteNode)
        }
       
        // collision with fireball and boss
        if ((firstBody.categoryBitMask == fireballCategory) &&
            (secondBody.categoryBitMask == bossCategory)) {
            
            collisionFireballWithBoss(firstBody.node as! SKSpriteNode, enemy: secondBody.node as! SKSpriteNode)
        }
        if ((firstBody.categoryBitMask == bossCategory) &&
            (secondBody.categoryBitMask == fireballCategory)) {

            collisionFireballWithBoss(secondBody.node as! SKSpriteNode, enemy: firstBody.node as! SKSpriteNode)
        }
        
        // collision with bFireball and mage
        if ((firstBody.categoryBitMask == bFireballCategory) &&
            (secondBody.categoryBitMask == playerCategory)) {
            
            runAction(SKAction.playSoundFileNamed("playerhit.mp3", waitForCompletion: true))
            isGameOver = true
        }
        if ((firstBody.categoryBitMask == playerCategory) &&
            (secondBody.categoryBitMask == bFireballCategory)) {
            
            runAction(SKAction.playSoundFileNamed("playerhit.mp3", waitForCompletion: true))
            isGameOver = true
        }

        // collision with bFireball and fireball
        if ((firstBody.categoryBitMask == bFireballCategory) &&
            (secondBody.categoryBitMask == fireballCategory)) {
            
             runAction(SKAction.playSoundFileNamed("playerhit.mp3", waitForCompletion: true))
             fireballParticalsAnimation(secondBody.node as! SKSpriteNode)

        }
        if ((firstBody.categoryBitMask == fireballCategory) &&
            (secondBody.categoryBitMask == bFireballCategory)) {
            
             runAction(SKAction.playSoundFileNamed("playerhit.mp3", waitForCompletion: true))
             fireballParticalsAnimation(firstBody.node as! SKSpriteNode)

        }
        
        // collision boss and playButton
        if ((firstBody.categoryBitMask == bossCategory) &&
            (secondBody.categoryBitMask == playButtonCategory)) ||
            ((firstBody.categoryBitMask == playButtonCategory) &&
                (secondBody.categoryBitMask == bossCategory)) {
            
            bossMoveDown()
        }
        
        // collision with boss and boundary
        if ((firstBody.categoryBitMask == bossCategory) &&
            (secondBody.categoryBitMask == boundaryCategory)) {
            
            bossMoveUp()
        }
        if ((firstBody.categoryBitMask == boundaryCategory) &&
            (secondBody.categoryBitMask == bossCategory)) {
            
            bossMoveUp()
        }
        
        
    }
    
    // COLLISION FUNCTIONS //////////////
    func collisionFireballWithBoss(fireball: SKSpriteNode, enemy: SKSpriteNode) {
        runAction(SKAction.playSoundFileNamed("enemyhit.mp3", waitForCompletion: true))
        fireballParticalsAnimation(fireball)
        bossHP = bossHP - 1
        if bossHP <= 0 {
            boss.removeFromParent()
            isGameWin = true
        }
        
    }
    
    func collisionLeftWallWithEnemy(leftWall: SKSpriteNode, enemy: SKSpriteNode) {
        enemy.removeFromParent()
    }
    
    func collisionFireballWithEnemy(fireball: SKSpriteNode, enemy: SKSpriteNode) {
        runAction(SKAction.playSoundFileNamed("enemyhit.mp3", waitForCompletion: true))
        deathAnimation(enemy)
        fireballParticalsAnimation(fireball)
    }
    
    func collisionFireballWithDemon(fireball: SKSpriteNode, demon: SKSpriteNode) {
        runAction(SKAction.playSoundFileNamed("enemyhit.mp3", waitForCompletion: true))
        deathAnimation(demon)
        fireballParticalsAnimation(fireball)
        demonCount = demonCount + 1
    
        if demonCount > 1 {
            spawnBoss()
        }
        
    }
    
}


















