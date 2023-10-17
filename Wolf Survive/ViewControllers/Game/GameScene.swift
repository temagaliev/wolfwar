//
//  GameScene.swift
//  Wolf Survive
//
//  Created by Artem Galiev on 13.10.2023.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    var backgraundNode = SKSpriteNode(imageNamed: NameImage.gameBg.rawValue)
    var playerNode = SKSpriteNode()
    var enemyNode = SKSpriteNode()

    let animationBombTime: [SKTexture] = [SKTexture(imageNamed: NameImage.bombOne.rawValue),
                                           SKTexture(imageNamed: NameImage.bombTwo.rawValue),
                                           SKTexture(imageNamed: NameImage.bombThree.rawValue),
                                           SKTexture(imageNamed: NameImage.bombFour.rawValue)]
    
    let animationBombFlame: [SKTexture] = [SKTexture(imageNamed: NameImage.flameOne.rawValue),
                                           SKTexture(imageNamed: NameImage.flameTwo.rawValue),
                                           SKTexture(imageNamed: NameImage.flameThree.rawValue)]
    

    let levelTimerLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
    var levelTimerValue: Int = 30

    var levelTimer = Timer()
    
    var isPlayerNodeOneTouched: Bool = false
    var isPlayerDead: Bool = false
    var isEnd: Bool = false
    
    var arrayUseNode: [SKSpriteNode] = []
    var angleShotEnemy: CGFloat = 0
    
    //Показатели сложности
    var intervalAttackBomb: TimeInterval = 5
    var intervalAttackBullet: TimeInterval = 5
    var timeBombFlame: TimeInterval = 0.8
    
    
    var level: Int = 1
    var starPointValue: Int = 0
    var gameVCDelegate: GameViewControllerDelegate?

    override func didMove(to view: SKView) {
        backgraundNode.position = CGPoint(x: 0, y: 0)
        backgraundNode.size = CGSize(width: frame.width, height: frame.height)
        
        addChild(backgraundNode)
        addChild(levelTimerLabel)

        self.physicsBody = SKPhysicsBody(edgeLoopFrom: self.frame)
        self.physicsBody?.friction = 0
        self.physicsBody?.restitution = 0
        self.physicsBody?.angularDamping = 0
        self.physicsBody?.categoryBitMask = UInt32(BodyType.wallGame)
        self.physicsBody?.collisionBitMask = UInt32(BodyType.enemy)
        self.physicsBody?.contactTestBitMask = UInt32(BodyType.enemy)
        
        view.scene?.delegate = self
        physicsWorld.contactDelegate = self

    }
    
    //MARK: - Начало игры
    public func startGame() {
        setupPlayer()
        setupEnemy()
        generateLevel()
        levelTimerLabel.text = String(levelTimerValue)
        startLevelTimer()
        starPointValue = 0
        moveEnemy(waitDuration: 5)
        attackEnemy(waitDuration: 5)
        attackBomb()
        isEnd = false
    }
    
    func startLevelTimer() {

        levelTimerLabel.fontColor = SKColor.white
        levelTimerLabel.fontSize = 40
        levelTimerLabel.position = CGPoint(x: frame.midX, y: frame.maxY / 1.35)

        levelTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(levelCountdown), userInfo: nil, repeats: true)

        levelTimerLabel.text = String(levelTimerValue)

    }
    
    @objc func levelCountdown() {
        levelTimerValue = levelTimerValue - 1
        levelTimerLabel.text = String(levelTimerValue)
        if levelTimerValue == 0 {
            SKAction.removeFromParent()
            self.removeAction(forKey: "forever")
            self.removeAction(forKey: "atack")
            self.removeAction(forKey: "bomb")
            if arrayUseNode.count != 0 {
                for node in arrayUseNode {
                    node.removeFromParent()
                }
                arrayUseNode = []
            }
            MainRouter.shared.showWinViewScreen(isWin: true, level: level, starValue: starPointValue)
            level = level + 1
            levelTimer.invalidate()

        }
        if levelTimerValue < 20 {
            intervalAttackBomb = intervalAttackBomb - 1
            intervalAttackBullet = intervalAttackBullet - 1
        }
    }
    
    //MARK: - Генерация уровней
    private func generateLevel() {
        switch level {
        case 1:
            intervalAttackBomb = 5
            intervalAttackBullet = 5
            levelTimerValue = 30
        case 2:
            intervalAttackBomb = 4
            intervalAttackBullet = 4.5
            timeBombFlame = 0.7
            levelTimerValue = 40
        case 3...5:
            intervalAttackBomb = 4
            intervalAttackBullet = 4.5
            timeBombFlame = 0.7
            levelTimerValue = 45
        case 6...10:
            intervalAttackBomb = 3.5
            intervalAttackBullet = 4
            timeBombFlame = 0.6
            levelTimerValue = 50
        case 11...20:
            intervalAttackBomb = 3
            intervalAttackBullet = 3.5
            levelTimerValue = 55
            timeBombFlame = 0.6
        case 21...40:
            intervalAttackBomb = 2
            intervalAttackBullet = 3
            levelTimerValue = 60
            timeBombFlame = 0.5
        case 41...150:
            intervalAttackBomb = 2
            intervalAttackBullet = 2
            levelTimerValue = 100
            timeBombFlame = 0.4
        case 151...1000:
            intervalAttackBomb = 1.5
            intervalAttackBullet = 2
            levelTimerValue = 300
            timeBombFlame = 0.3
        case 1001...10000:
            intervalAttackBomb = 1.5
            intervalAttackBullet = 1.5
            levelTimerValue = 500
            timeBombFlame = 0.2
        default:
            intervalAttackBomb = 5
            intervalAttackBullet = 5
            levelTimerValue = 30
            timeBombFlame = 0.8
        }
    }
    
    //MARK: - Настройки модели игрока
    private func setupPlayer() {
        playerNode = SKSpriteNode(imageNamed: NameImage.player.rawValue)
        playerNode.size = CGSize(width: 50, height: 50)
        playerNode.position = CGPoint(x: frame.midX, y: frame.midY - 100)
        playerNode.physicsBody = SKPhysicsBody(rectangleOf: playerNode.size)
        playerNode.physicsBody?.categoryBitMask = UInt32(BodyType.player)
        playerNode.physicsBody?.collisionBitMask = 0
        playerNode.physicsBody?.contactTestBitMask = UInt32(BodyType.enemy)

        playerNode.physicsBody?.affectedByGravity = false
        playerNode.physicsBody?.isDynamic = false
        arrayUseNode.append(playerNode)
        addChild(playerNode)
    }
    
    //MARK: - Настройки модели врага
    private func setupEnemy() {
        enemyNode = SKSpriteNode(imageNamed: NameImage.wolfPerson.rawValue)
        enemyNode.size = CGSize(width: 100, height: 100)
        enemyNode.position = CGPoint(x: frame.midX, y: frame.midY + 100)
        enemyNode.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 0, height: 0))
        enemyNode.physicsBody?.affectedByGravity = false
        enemyNode.physicsBody?.isDynamic = false
        arrayUseNode.append(enemyNode)

        addChild(enemyNode)

    }
    
    //MARK: - Touches
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            if playerNode.contains(touch.location(in: self)) {
                isPlayerNodeOneTouched = true
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        movePlayer(isPlayer: isPlayerNodeOneTouched, player: playerNode, isDead: false, touches: touches)
    }
    
    //MARK: - Движение игрока
    private func movePlayer(isPlayer: Bool, player: SKSpriteNode, isDead: Bool, touches: Set<UITouch>) {
        if isDead == false {
            if isPlayer == true {
                if let touch = touches.first {
                    let touchLoc = touch.location(in: self)
                    let prevTouchLoc = touch.previousLocation(in: self)
                    let location = touch.location(in: self)

                    let move = SKAction.move(to: location, duration: 0.1)
                    player.run(move)
                    let newYPos = player.position.y + (touchLoc.y - prevTouchLoc.y)
                    let newXPos = player.position.x + (touchLoc.x - prevTouchLoc.x)
                    player.position = CGPoint(x: newXPos, y: newYPos)
                }
            }
        }
    }
    
    //MARK: - Движение врага
    private func moveEnemy(waitDuration: TimeInterval) {
        let actionMain = SKAction.customAction(withDuration: 0) { [weak self] _,_ in
            guard let self else { return }
            
            let actionMove = SKAction.customAction(withDuration: 0) { node, _ in
                let distance = sqrt(pow(Double(self.enemyNode.position.x - self.playerNode.position.x), 2) + pow(Double(self.enemyNode.position.y - self.playerNode.position.y), 2))
                let time = distance / 30
                let move = SKAction.move(to: CGPoint(x: self.playerNode.position.x / 2, y: self.playerNode.position.y / 2), duration: time)
                let dx = self.playerNode.position.x - self.enemyNode.position.x
                let dy = self.playerNode.position.y - self.enemyNode.position.y
                let angle = atan2(dx, -dy)
                self.angleShotEnemy = angle
                let rotate = SKAction.rotate(toAngle: angle, duration: 3)
                node.run(rotate)
                node.run(move)
            }
            
            let waitForViewAction = SKAction.wait(forDuration: waitDuration)
            let sequance = SKAction.sequence([actionMove, waitForViewAction])
            
            enemyNode.run(sequance)
        }
        let waitForViewAction = SKAction.wait(forDuration: waitDuration)
        let sequance = SKAction.sequence([actionMain, waitForViewAction])
        
        self.run(SKAction.repeatForever(sequance), withKey: "forever")
    }
    
    //MARK: - Атаки врага
    private func attackEnemy(waitDuration: TimeInterval) {
        let actionMain = SKAction.customAction(withDuration: 0) { [weak self] _,_ in
            guard let self else { return }
            
            let actionShot = SKAction.customAction(withDuration: 0, actionBlock: { node,_ in
                let random = Int.random(in: 1...10)
                if random > 7 {
                    self.attackEnemyBullet(isAround: true)
                } else {
                    self.attackEnemyBullet(isAround: false)
                }
            })
            
            let waitForViewAction = SKAction.wait(forDuration: 0.3)
            let sequance = SKAction.sequence([actionShot, waitForViewAction, actionShot,waitForViewAction, actionShot, waitForViewAction, actionShot])

            enemyNode.run(sequance)
        }
        let waitForViewAction = SKAction.wait(forDuration: intervalAttackBullet)
        let sequance = SKAction.sequence([actionMain, waitForViewAction])
        
        self.run(SKAction.repeatForever(sequance), withKey: "atack")
        
    }
    
    //MARK: - Атаки бомбами
    private func attackBomb() {
        let actionMain = SKAction.customAction(withDuration: 0) { [weak self] _,_ in
            guard let self else { return }
            self.attackEnemyBomb()
        }
        let waitForViewAction = SKAction.wait(forDuration: intervalAttackBomb)
        let sequance = SKAction.sequence([actionMain, waitForViewAction])
        
        self.run(SKAction.repeatForever(sequance), withKey: "bomb")
        
    }
    
    //MARK: - attackEnemyBomb
    private func attackEnemyBomb() {
        let bombEnemyNode = SKSpriteNode(imageNamed: NameImage.bombOne.rawValue)
        
        bombEnemyNode.size = CGSize(width: 30, height: 30)
        bombEnemyNode.position = enemyNode.position
        bombEnemyNode.physicsBody = SKPhysicsBody(circleOfRadius: 15)
        
        bombEnemyNode.physicsBody?.affectedByGravity = false
        bombEnemyNode.physicsBody?.usesPreciseCollisionDetection = true
        bombEnemyNode.physicsBody?.collisionBitMask = 0

        arrayUseNode.append(bombEnemyNode)
        addChild(bombEnemyNode)

        var actionArray = [SKAction]()
        let animationDuration: TimeInterval = 1
        let bombAnimation = SKAction.animate(with: animationBombTime,
                                             timePerFrame: timeBombFlame)
        let flameAnimation = SKAction.animate(with: animationBombFlame,
                                              timePerFrame: 0.3)
        
        
        let actionMain = SKAction.customAction(withDuration: 0) { _,_ in
            bombEnemyNode.size = CGSize(width: 60, height: 60)
            bombEnemyNode.physicsBody = SKPhysicsBody(circleOfRadius: 30)
            bombEnemyNode.physicsBody?.affectedByGravity = false
            bombEnemyNode.physicsBody?.categoryBitMask = UInt32(BodyType.enemy)
            bombEnemyNode.physicsBody?.collisionBitMask = 0
            bombEnemyNode.physicsBody?.contactTestBitMask = UInt32(BodyType.player)

        }

        actionArray.append(SKAction.move(to: CGPoint(x: playerNode.position.x, y: playerNode.position.y), duration: animationDuration))
        actionArray.append(bombAnimation)
        actionArray.append(actionMain)
        actionArray.append(flameAnimation)
        actionArray.append(SKAction.removeFromParent())
        bombEnemyNode.run(SKAction.sequence(actionArray))
        
        let starNode = SKSpriteNode(imageNamed: NameImage.starPoint.rawValue)

        starNode.size = CGSize(width: 15, height: 15)
        let randomX = CGFloat.random(in: frame.minX + 50...frame.maxX - 50)
        let randomY = CGFloat.random(in: frame.minY + 100...frame.maxY - 100)

        starNode.position = CGPoint(x: randomX, y: randomY)
        starNode.physicsBody = SKPhysicsBody(rectangleOf: starNode.size)
        starNode.physicsBody?.affectedByGravity = false
        starNode.physicsBody?.usesPreciseCollisionDetection = true
        starNode.physicsBody?.categoryBitMask = UInt32(BodyType.star)
        starNode.physicsBody?.collisionBitMask = 0
        starNode.physicsBody?.contactTestBitMask = UInt32(BodyType.player)
        arrayUseNode.append(starNode)
        addChild(starNode)
    
    }
    
    //MARK: - attackEnemyBullet
    private func attackEnemyBullet(isAround: Bool) {
        let dx = enemyNode.position.x
        let dy = enemyNode.position.y
        let angle = atan2(-dx, dy)
        if enemyNode.position.x != 0 && enemyNode.position.y != 0 {
            let bulletEnemyNode = SKSpriteNode(imageNamed: NameImage.comet.rawValue)
            
            bulletEnemyNode.size = CGSize(width: 15, height: 15)
            bulletEnemyNode.position = enemyNode.position
            bulletEnemyNode.physicsBody = SKPhysicsBody(circleOfRadius: 5)
            
            bulletEnemyNode.physicsBody?.affectedByGravity = false
            bulletEnemyNode.physicsBody?.usesPreciseCollisionDetection = true
            
            bulletEnemyNode.physicsBody?.categoryBitMask = UInt32(BodyType.enemy)
            bulletEnemyNode.physicsBody?.collisionBitMask = 0
            bulletEnemyNode.physicsBody?.contactTestBitMask = UInt32(BodyType.wallGame)
            
            let bulletEnemyNodeTwo = SKSpriteNode(imageNamed: NameImage.comet.rawValue)
            
            bulletEnemyNodeTwo.size = CGSize(width: 15, height: 15)
            bulletEnemyNodeTwo.position = enemyNode.position
            
            bulletEnemyNodeTwo.physicsBody = SKPhysicsBody(circleOfRadius: 5)
            
            bulletEnemyNodeTwo.physicsBody?.affectedByGravity = false
            bulletEnemyNodeTwo.physicsBody?.usesPreciseCollisionDetection = true
            
            bulletEnemyNodeTwo.physicsBody?.categoryBitMask = UInt32(BodyType.enemy)
            bulletEnemyNodeTwo.physicsBody?.collisionBitMask = 0
            bulletEnemyNodeTwo.physicsBody?.contactTestBitMask = UInt32(BodyType.wallGame)
            
            let bulletEnemyNodeThree = SKSpriteNode(imageNamed: NameImage.comet.rawValue)
            
            bulletEnemyNodeThree.size = CGSize(width: 15, height: 15)
            bulletEnemyNodeThree.position = enemyNode.position
            
            bulletEnemyNodeThree.physicsBody = SKPhysicsBody(circleOfRadius: 5)
            
            bulletEnemyNodeThree.physicsBody?.affectedByGravity = false
            bulletEnemyNodeThree.physicsBody?.usesPreciseCollisionDetection = true
            
            bulletEnemyNodeThree.physicsBody?.categoryBitMask = UInt32(BodyType.enemy)
            bulletEnemyNodeThree.physicsBody?.collisionBitMask = 0
            bulletEnemyNodeThree.physicsBody?.contactTestBitMask = UInt32(BodyType.wallGame)
            
            let bulletEnemyNodeFour = SKSpriteNode(imageNamed: NameImage.comet.rawValue)
            
            bulletEnemyNodeFour.size = CGSize(width: 15, height: 15)
            bulletEnemyNodeFour.position = enemyNode.position
            
            bulletEnemyNodeFour.physicsBody = SKPhysicsBody(circleOfRadius: 5)
            
            bulletEnemyNodeFour.physicsBody?.affectedByGravity = false
            bulletEnemyNodeFour.physicsBody?.usesPreciseCollisionDetection = true
            
            bulletEnemyNodeFour.physicsBody?.categoryBitMask = UInt32(BodyType.enemy)
            bulletEnemyNodeFour.physicsBody?.collisionBitMask = 0
            bulletEnemyNodeFour.physicsBody?.contactTestBitMask = UInt32(BodyType.wallGame)
            
            let speed: CGFloat = 50
            
            //Лево
            arrayUseNode.append(bulletEnemyNode)
            addChild(bulletEnemyNode)
            bulletEnemyNode.physicsBody?.applyForce(CGVector(dx: cos(angle) * -(speed) , dy: sin(angle) * -(speed) ))
            //Прямо
            arrayUseNode.append(bulletEnemyNodeTwo)
            addChild(bulletEnemyNodeTwo)
            bulletEnemyNodeTwo.physicsBody?.applyForce(CGVector(dx: sin(angle) * -(speed) , dy: cos(angle) * (speed)))
            //Право
            arrayUseNode.append(bulletEnemyNodeThree)
            addChild(bulletEnemyNodeThree)
            bulletEnemyNodeThree.physicsBody?.applyForce(CGVector(dx: cos(angle) * (speed) , dy: sin(angle) * (speed) ))
            //Назад
            arrayUseNode.append(bulletEnemyNodeFour)
            addChild(bulletEnemyNodeFour)
            bulletEnemyNodeFour.physicsBody?.applyForce(CGVector(dx: sin(angle) * (speed) , dy: cos(angle) * -(speed) ))
            
            
            if isAround {
                let bulletEnemyNode1 = SKSpriteNode(imageNamed: NameImage.comet.rawValue)
                
                bulletEnemyNode1.size = CGSize(width: 15, height: 15)
                bulletEnemyNode1.position = enemyNode.position
                
                bulletEnemyNode1.physicsBody = SKPhysicsBody(circleOfRadius: 5)
                
                bulletEnemyNode1.physicsBody?.affectedByGravity = false
                bulletEnemyNode1.physicsBody?.usesPreciseCollisionDetection = true
                
                bulletEnemyNode1.physicsBody?.categoryBitMask = UInt32(BodyType.enemy)
                bulletEnemyNode1.physicsBody?.collisionBitMask = 0
                bulletEnemyNode1.physicsBody?.contactTestBitMask = UInt32(BodyType.wallGame)
                
                let bulletEnemyNode2 = SKSpriteNode(imageNamed: NameImage.comet.rawValue)
                
                bulletEnemyNode2.size = CGSize(width: 15, height: 15)
                bulletEnemyNode2.position = enemyNode.position
                
                bulletEnemyNode2.physicsBody = SKPhysicsBody(circleOfRadius: 5)
                
                bulletEnemyNode2.physicsBody?.affectedByGravity = false
                bulletEnemyNode2.physicsBody?.usesPreciseCollisionDetection = true
                
                bulletEnemyNode2.physicsBody?.categoryBitMask = UInt32(BodyType.enemy)
                bulletEnemyNode2.physicsBody?.collisionBitMask = 0
                bulletEnemyNode2.physicsBody?.contactTestBitMask = UInt32(BodyType.wallGame)
                
                let bulletEnemyNode3 = SKSpriteNode(imageNamed: NameImage.comet.rawValue)
                
                bulletEnemyNode3.size = CGSize(width: 15, height: 15)
                bulletEnemyNode3.position = enemyNode.position
                
                bulletEnemyNode3.physicsBody = SKPhysicsBody(circleOfRadius: 5)
                
                bulletEnemyNode3.physicsBody?.affectedByGravity = false
                bulletEnemyNode3.physicsBody?.usesPreciseCollisionDetection = true
                
                bulletEnemyNode3.physicsBody?.categoryBitMask = UInt32(BodyType.enemy)
                bulletEnemyNode3.physicsBody?.collisionBitMask = 0
                bulletEnemyNode3.physicsBody?.contactTestBitMask = UInt32(BodyType.wallGame)
                
                let bulletEnemyNode4 = SKSpriteNode(imageNamed: NameImage.comet.rawValue)
                
                bulletEnemyNode4.size = CGSize(width: 15, height: 15)
                bulletEnemyNode4.position = enemyNode.position
                
                bulletEnemyNode4.physicsBody = SKPhysicsBody(circleOfRadius: 5)
                
                bulletEnemyNode4.physicsBody?.affectedByGravity = false
                bulletEnemyNode4.physicsBody?.usesPreciseCollisionDetection = true
                
                bulletEnemyNode4.physicsBody?.categoryBitMask = UInt32(BodyType.enemy)
                bulletEnemyNode4.physicsBody?.collisionBitMask = 0
                bulletEnemyNode4.physicsBody?.contactTestBitMask = UInt32(BodyType.wallGame)
                

                //правоверх
                addChild(bulletEnemyNode1)
                arrayUseNode.append(bulletEnemyNode1)
                bulletEnemyNode1.physicsBody?.applyForce(CGVector(dx: cos(angle) * (speed) , dy: cos(angle) * (speed) ))

                //Левоверех
                addChild(bulletEnemyNode2)
                arrayUseNode.append(bulletEnemyNode2)
                bulletEnemyNode2.physicsBody?.applyForce(CGVector(dx: cos(angle) * (speed) , dy: cos(angle) * -(speed) ))

                //правоверх
                addChild(bulletEnemyNode3)
                arrayUseNode.append(bulletEnemyNode3)
                bulletEnemyNode3.physicsBody?.applyForce(CGVector(dx: cos(angle) * -(speed) , dy: cos(angle) * -(speed) ))

                //правовниз
                addChild(bulletEnemyNode4)
                arrayUseNode.append(bulletEnemyNode4)
                bulletEnemyNode4.physicsBody?.applyForce(CGVector(dx: cos(angle) * -(speed) , dy: cos(angle) * (speed) ))
            }
        }
    }
}



//MARK: - SKSceneDelegate
extension GameScene: SKSceneDelegate {
    override func update(_ currentTime: TimeInterval) {
        if isEnd == false {
            if isPlayerDead {
                isEnd = true
                isPlayerDead = false
                levelTimer.invalidate()
                SKAction.removeFromParent()
                self.removeAction(forKey: "forever")
                self.removeAction(forKey: "atack")
                self.removeAction(forKey: "bomb")
                if arrayUseNode.count != 0 {
                    for node in arrayUseNode {
                        node.removeFromParent()
                    }
                    arrayUseNode = []
                }
                MainRouter.shared.showWinViewScreen(isWin: false, level: level, starValue: starPointValue)
                level = 1
            }
        }
    }
}

//MARK: - SKPhysicsContactDelegate
extension GameScene: SKPhysicsContactDelegate {
    //Столкновения
    func didBegin(_ contact: SKPhysicsContact) {
        //Переменные контакта
        let bodyA = contact.bodyA.categoryBitMask
        let bodyB = contact.bodyB.categoryBitMask
        
        let enemy = UInt32(BodyType.enemy)
        let wall = UInt32(BodyType.wallGame)
        let player = UInt32(BodyType.player)
        let starNode = UInt32(BodyType.star)

        if bodyA == player && bodyB == starNode {
            contact.bodyB.node?.removeFromParent()
            starPointValue = starPointValue + 1
            gameVCDelegate?.counterStarValue(starValue: starPointValue)
        }
        
        if bodyA == starNode && bodyB == player {
            contact.bodyA.node?.removeFromParent()
            starPointValue = starPointValue + 1
            gameVCDelegate?.counterStarValue(starValue: starPointValue)
        }
        
        if bodyA == wall && bodyB == enemy {
            contact.bodyB.node?.removeFromParent()
        }
        
        if bodyA == enemy && bodyB == wall {
            contact.bodyA.node?.removeFromParent()
        }
        
        if bodyA == player && bodyB == enemy || bodyA == enemy && bodyB == player {
            isPlayerDead = true
        }
    }
}
