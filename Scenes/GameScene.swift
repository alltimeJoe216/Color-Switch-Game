//
//  GameScene.swift
//  ColorSwitch
//
//  Created by Marissa Gonzales on 3/21/20.
//  Copyright © 2020 Joe Veverka. All rights reserved.
//

import SpriteKit

// enum for ball colors

enum PlayCOlors {
    static let colors = [
        UIColor(red: 231/255, green: 76/255, blue: 60/255, alpha: 1.0),
        UIColor(red: 241/255, green: 196/255, blue: 15/255, alpha: 1.0),
        UIColor(red: 46/255, green: 204/255, blue: 113/255, alpha: 1.0),
        UIColor(red: 52/255, green: 152/255, blue: 219/255, alpha: 1.0)
    ]
}

enum SwitchState: Int {
    case red, yellow, green, blue
}

class GameScene: SKScene {
    
    // create colorSwitch, it's switchState, and current color
    
    var colorSwitch: SKSpriteNode!
    var switchState = SwitchState.red
    var currentColorIndex: Int?
    
    // create score label
    
    let scoreLabel = SKLabelNode(text: "0")
    var score = 0
    
    
    
    override func didMove(to view: SKView) {
        setUpPhysics()
        layoutScene()
        
       }
    
    // slow down gravity
    func setUpPhysics() {
        physicsWorld.gravity = CGVector(dx: 0.0, dy: -2.5)
        physicsWorld.contactDelegate = self
        }
    
   
    func layoutScene() {
        
        // background color
        backgroundColor = UIColor(red: 44/255, green: 62/255, blue: 80/255, alpha: 1.0)
        
        // Determining colorswitch and all of it's size properties
        
        colorSwitch = SKSpriteNode(imageNamed: "ColorCircle")
        colorSwitch.size = CGSize(width: frame.size.width/3, height: frame.size.width/3) // <--- Size of color Switch
        colorSwitch.position = CGPoint(x: frame.midX, y: frame.minY + colorSwitch.size.height) // <--- setting position on VC
        colorSwitch.zPosition = Zpositions.colorSwitch // <--- depth of node within the VC
        
        // Adding physics properties to colorSwitch
        colorSwitch.physicsBody = SKPhysicsBody(circleOfRadius: colorSwitch.size.width / 2) // setting physicsbody properties
        colorSwitch.physicsBody?.categoryBitMask = PhysicsCategories.switchCategory
        
        /*
         the next piece of code determines that the colorSwitch will NOT have a volume-based body.
         this means it will not be affected by gravity, friction, collisions etc.
         */
        
        colorSwitch.physicsBody?.isDynamic = false
        
        // Adding the view to the VC
        
        addChild(colorSwitch)
        
        // Determining label font, size and position values
        
        scoreLabel.fontName = "AvenirNext-Bold"
        scoreLabel.fontSize = 60.0
        scoreLabel.fontColor = UIColor.white
        scoreLabel.position = CGPoint(x: frame.midX, y: frame.midY)
        scoreLabel.zPosition = Zpositions.label // <--- determines depth level in VC
        // adding to VC
        addChild(scoreLabel)
        
        // spawnBall function (created below)
        spawnBall()
        
        }
    
        // Calling Update score label method 
    func updateScoreLabel() {
        scoreLabel.text = "\(score)"
    }
    
    
    // create ball properties/size etc
    func spawnBall() {
        
        //randomize color of ball at beginning of game
        
        currentColorIndex = Int(arc4random_uniform(UInt32(4)))
        
        
        // ball size and physics properties
        let ball = SKSpriteNode(texture: SKTexture(imageNamed: "ball"), color: PlayCOlors.colors[currentColorIndex!], size: CGSize(width: 30.0, height: 30.0))
        ball.colorBlendFactor = 1.0
        ball.name = "Ball"
        ball.position = CGPoint(x: frame.midX, y: frame.maxY)
        ball.zPosition = Zpositions.ball
        //
        ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.size.width / 2)
        ball.physicsBody?.categoryBitMask = PhysicsCategories.ballCategory
        ball.physicsBody?.contactTestBitMask = PhysicsCategories.switchCategory
        ball.physicsBody?.collisionBitMask = PhysicsCategories.none
        addChild(ball)
        
           }
    
            // Turn the color wheel
            func turnWheel() {
                if let newState = SwitchState(rawValue: switchState.rawValue + 1) {
                    switchState = newState
                } else {
                    switchState = .red
                }
                
                colorSwitch.run(SKAction.rotate(byAngle: .pi/2, duration: 0.25))
        }
    
    
    // calling touchesBegan and it will run the turn the color wheel method when screen is tapped.
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        turnWheel()
    }
    
    func gameOver() {
        
        // Allowing high scores and recent scores to be added to main menu
        UserDefaults.standard.set(score, forKey: "Recent Score")
        if score > UserDefaults.standard.integer(forKey: "Highscore") {
            UserDefaults.standard.set(score, forKey: "Highscore") 
            
        }
        
        // return to menu when game is over
        let menu = MenuScene(size: view!.bounds.size)
        view!.presentScene(menu)
        
    }
}
// setup contact relationship between ball and colorswitch
extension GameScene: SKPhysicsContactDelegate {
    
    func didBegin(_ contact: SKPhysicsContact) {
        // 01
        // 10
        // 11
        
        
        /*
         the rest of the code determines whether or not the player is connecting
         the correct color ball to the correct color of colorswitch
         */
        
        let contactMask = contact.bodyA.categoryBitMask |
            contact.bodyB.categoryBitMask
        
        
        if contactMask == PhysicsCategories.ballCategory | PhysicsCategories.switchCategory {
            if let ball = contact.bodyA.node?.name == "Ball" ? contact.bodyA.node as? SKSpriteNode
                : contact.bodyB.node as? SKSpriteNode {
                if currentColorIndex == switchState.rawValue {
                    run(SKAction.playSoundFileNamed("bling", waitForCompletion: false)) //<--- sound when you get a point
                    score += 1
                    updateScoreLabel()
                    
                    ball.run(SKAction.fadeOut(withDuration: 0.25), completion: {
                        ball.removeFromParent()
                        self.spawnBall()
                })
                } else {
                    gameOver()
                }
            }
        }
    }
}
 
