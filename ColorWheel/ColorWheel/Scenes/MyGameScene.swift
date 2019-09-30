import SpriteKit
class MyGameScene: SKScene {
    var colorSwitch: SKSpriteNode!     
    var switchState = SwitchState.pink 
    var currentColorIndex: Int?        
    var scoreLabel: SKLabelNode!       
    var score = 0                      
    override func didMove(to view: SKView) {
        setUpPhysics()
        layoutScene()
    }
    func setUpPhysics() {
        physicsWorld.gravity = CGVector(dx: 0.0, dy: -1.5)
        physicsWorld.contactDelegate = self
    }
    func updatePhysicsWorld() {
        physicsWorld.gravity.dy -= CGFloat(0.5)
    }
    func layoutScene() {
        backgroundColor = Layout.backgroundColor
        colorSwitch = createSpriteNode(node: SKSpriteNode(imageNamed: "colorCircle"), name: "ColorSwitch", size: CGSize(width: frame.size.width/2.5, height: frame.size.width/2.5), position: CGPoint(x: frame.midX, y: frame.minY+(frame.size.width/2.5)), zPosition: ZPostions.colorSwitch, physicsCategory: PhysicsCategories.switchCategory)
        colorSwitch.physicsBody?.isDynamic = false
        scoreLabel = createTextNode(text: "0", nodeName: "ScoreLabel", position: CGPoint(x: frame.midX, y: frame.midY), fontSize: CGFloat(60.0), fontColor: UIColor.white)
        addChild(colorSwitch)
        addChild(scoreLabel)
        releaseBall()
    }
    func updateScoreAndScoreLabel(){
        score += 1
        scoreLabel.text = "\(score)"
        run(SKAction.playSoundFileNamed("success", waitForCompletion: false))
        if score % 5 == 0 {
            updatePhysicsWorld()
        }
    }
    func releaseBall() {
        currentColorIndex = Int(arc4random_uniform(UInt32(6)))
        let ball = createSpriteNode(node: SKSpriteNode(texture: SKTexture(imageNamed: "ballImage")), name: "Ball", size: CGSize(width: 30.0, height: 30.0), position: CGPoint(x: frame.midX, y: frame.maxY), zPosition: ZPostions.ball, physicsCategory: PhysicsCategories.ballCategory)
        ball.color = GameColors.colors[currentColorIndex!]
        ball.colorBlendFactor = 1.0
        ball.physicsBody?.contactTestBitMask = PhysicsCategories.switchCategory
        ball.physicsBody?.collisionBitMask = PhysicsCategories.none
        addChild(ball)
    }
    func turnWheel() {
        if let newState = SwitchState(rawValue: switchState.rawValue + 1){
            switchState = newState
        }else{
            switchState = .maroon
        }
        colorSwitch.run(SKAction.rotate(byAngle: .pi/3, duration: 0.167))
    }
    func gameOver() {
        UserDefaults.standard.set(score, forKey: "recent_score")
        if score > UserDefaults.standard.integer(forKey: "high_score"){
            UserDefaults.standard.set(score, forKey: "high_score")
        }
        let menuScene = MyMenuScene(size: view!.bounds.size)
        view!.presentScene(menuScene)
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        turnWheel()
    }
}
extension MyGameScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        let contactMask = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        if contactMask == PhysicsCategories.ballCategory | PhysicsCategories.switchCategory{
            if let ball = contact.bodyA.node?.name == "Ball" ? contact.bodyA.node as? SKSpriteNode : contact.bodyB.node as? SKSpriteNode {
                if currentColorIndex == switchState.rawValue {
                    updateScoreAndScoreLabel()
                    ball.run(SKAction.fadeOut(withDuration: 0.25), completion: {
                        ball.removeFromParent()
                        self.releaseBall()
                    })
                }else{
                    gameOver()
                }
            }
        }
    }
}
