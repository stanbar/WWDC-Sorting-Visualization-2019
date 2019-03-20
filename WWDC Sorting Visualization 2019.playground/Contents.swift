//: A SpriteKit based Playground

import PlaygroundSupport
import SpriteKit

struct Block : Comparable, Hashable {
    static func < (left: Block, right: Block) -> Bool {
        return left.area < right.area
    }
    
    var node : SKShapeNode
    var area : CGFloat{
        return node.frame.width * node.frame.height
    }
    var left : CGFloat{
        return node.frame.minX
    }
    var right : CGFloat{
        return node.frame.maxX
    }
    var x : CGFloat {
        return node.position.x
    }
}



class GameScene: SKScene {
    
    private var blockSize : CGSize!
    private var blocks : [Block] = []
    private var blockAdding = false
    override func didMove(to view: SKView) {
        physicsWorld.gravity = CGVector.zero
        backgroundColor = SKColor.white
        let w = (size.width + size.height) * 0.05
        blockSize = CGSize(width: w, height: w)
        let logo = SKSpriteNode(imageNamed: "LogoBlackWWDC19")
        logo.name = "logo"
        logo.setScale(1.0)
        logo.position = CGPoint(x: frame.midX, y: frame.midY)
        addChild(logo)
    }
    
    func newBlock(at pos : CGPoint, _ color : NSColor) -> Block{
        let node = SKShapeNode(rectOf: blockSize)
        node.position = pos
        node.strokeColor = color
        node.fillColor = color
        node.run(
            .repeatForever(
                .sequence([.scale(by: 0.5, duration: 1),
                           .scale(by: 2.0, duration: 1)])))
        
        let block = Block(node: node)
        return block
    }
    
    @objc static override var supportsSecureCoding: Bool {
        // SKNode conforms to NSSecureCoding, so any subclass going
        // through the decoding process must support secure coding
        get {
            return true
        }
    }
    
    
    
    func sort(){
        bubblesort()
    }
    
    func quicksort<T: Comparable>(_ a: [T]) -> [T] {
        guard a.count > 1 else { return a }
        let pivot = a[a.count/2]
        let less = a.filter { $0 < pivot }
        let equal = a.filter { $0 == pivot }
        let greater = a.filter { $0 > pivot }
        
        return quicksort(less) + equal + quicksort(greater)
    }
    let animationDuration = 0.3
    func bubblesort(){
        var actions : [(Block?, SKAction)] = []
        var positions : [Block?: CGFloat] = [:]
        for block in blocks{
            positions[block] = block.x
        }
        
        for i in 0..<blocks.count {
            for j in 1..<blocks.count - i {
                if blocks[j] < blocks[j-1] {
                    let tmp = blocks[j-1]
                    blocks[j-1] = blocks[j]
                    blocks[j] = tmp
                    
                    let tempPosition = positions[blocks[j-1]]
                    positions[blocks[j-1]] = positions[blocks[j]]
                    positions[blocks[j]] = tempPosition
                    
                    actions.append((blocks[j-1], SKAction.moveTo(x: positions[blocks[j-1]]!, duration: animationDuration)))
                    actions.append((blocks[j], SKAction.moveTo(x: positions[blocks[j]]!, duration: animationDuration)))
                    
                }
            }
        }
        // Unset semaphore after all actions are executed
        actions.append((blocks.first, SKAction.run{ self.blockAdding = false }))
    
        var duration = 0.0
        var replacedBothOfPair = false
        for (block, action) in actions{
            block?.node.run(SKAction.sequence([.wait(forDuration: duration), action]))
            // Execute both actions at once
            if replacedBothOfPair{
                duration += animationDuration
            }
            replacedBothOfPair = !replacedBothOfPair
        }
        
    }
    
    func area(of node : SKNode) -> CGFloat{
        return node.frame.width * node.frame.height
    }
    
    func replace(_ first : Block, _ second : Block) -> (SKAction, SKAction){
        let firstReplace = SKAction.sequence([
            .wait(forDuration: 0.5),
            .moveTo(x: second.x, duration: 0.5)
            ])
        
        let secondReplace = SKAction.sequence([
            .wait(forDuration: 0.5),
            .moveTo(x: first.x, duration: 0.5)
            ])
        
        return (firstReplace, secondReplace)
        
    }
    
    
    
    
    override func mouseDown(with event: NSEvent) {
        touchDown(atPoint: event.location(in: self))
    }
    
    override func mouseDragged(with event: NSEvent) {
        touchMoved(toPoint: event.location(in: self))
    }
    
    override func mouseUp(with event: NSEvent) {
        touchUp(atPoint: event.location(in: self))
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
    
    var creatingBlock : Block?
    
    func touchDown(atPoint pos : CGPoint) {
        if blockAdding {
            print("Can not add new block right now")
            return
        }
        blockAdding = true
        let creatingBlock = startNewBlockCreation(atPoint : pos)
        self.creatingBlock = creatingBlock
        addChild(creatingBlock.node)
    }
    
    func startNewBlockCreation(atPoint pos : CGPoint) -> Block{
        let creatingBlock = newBlock(at : pos,
                                    SKColor(red: CGFloat.random(in: 0.3...1.0),
                                            green: CGFloat.random(in: 0.3...1.0),
                                            blue: CGFloat.random(in: 0.3...1.0),
                                            alpha: CGFloat.random(in: 0.9...1.0)))
        creatingBlock.node.run(
            .repeatForever(
            .sequence([.scale(by: 0.5, duration: 1),
                       .scale(by: 2.0, duration: 1)])))
        
        return creatingBlock
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        moveNewBlockCreation(atPoint : pos)
        
    }
    
    func moveNewBlockCreation(atPoint pos : CGPoint){
        guard let creatingBlock = self.creatingBlock as Block? else { return }
        creatingBlock.node.position = pos
    }
    
    func touchUp(atPoint pos : CGPoint) {
        endNewBlockCreation(atPoint : pos)
        
    }
    
    func endNewBlockCreation(atPoint pos : CGPoint){
        guard let creatingBlock = self.creatingBlock as Block? else { return }
        creatingBlock.node.removeAllActions()
        creatingBlock.node.position = pos
        let insertIndex = findInsertIndex(for: pos)
        print("indert new block in at index\(insertIndex)")
        blocks.insert(creatingBlock, at: insertIndex)
        makeSpace(for: creatingBlock)
        creatingBlock.node.run(SKAction.sequence([
            .moveTo(y: creatingBlock.node.frame.height/2, duration: 0.5),
            .run { self.sort()}
            ]))
        self.creatingBlock = nil
        
    }
    
    func findInsertIndex(for position: CGPoint) -> Int {
        if blocks.count == 0 {return 0}
        var indexToInsert = 0
        for block in blocks{
            if block.x <= position.x{ indexToInsert = indexToInsert + 1 }
        }
        return indexToInsert
    }
    
    func makeSpace(for newBlock : Block){
        // find matching
        var moveLeft : CGFloat = 0.0
        var moveRight : CGFloat = 0.0
        for block in blocks{
            if(block == newBlock){continue}
            var willCollide = false
            if newBlock.left == block.right && //   [new]
                newBlock.left == block.right{ //    [old]
                willCollide = true
                print("Collistion detected")
                print("[new]")
                print("[old]")
            }
            if newBlock.left >= block.left &&
                newBlock.left <= block.right &&
                newBlock.right >= block.right{
                willCollide = true
                print("Collision detected")
                print("   [new]")
                print("[old]")
            }
            if newBlock.left <= block.left && //  [new]
                newBlock.right >= block.left && //     <>
                newBlock.right <= block.right{ //     [old]
                willCollide = true
                print("Collision detected")
                print("[new]")
                print("   [old]")
            }
            if newBlock.left >= block.left && //  [new]
                newBlock.right <= block.right { // [ old ]
                willCollide = true
                print("Collision detected")
                print("  [new]")
                print("[  old  ]")
            }
            
            if newBlock.left <= block.left && //  [ new ]
                newBlock.right >= block.right{ //     [old]
                willCollide = true
                print("Collision detected")
                print("[  new  ]")
                print("  [old]")
            }
            if !willCollide {continue}
            if newBlock.x >= block.x && newBlock.left < block.right{
                moveLeft = block.right - newBlock.left
            }else if newBlock.x < block.x && newBlock.right > block.left{
                moveRight = newBlock.right - block.left
            }
        }
        
        
        for block in self.blocks{
            if(block == newBlock){continue}
            let garbageCollection = SKAction.run {
                if block.right < 0.0 || block.left > self.size.width {
                    block.node.removeFromParent()
                    self.blocks.remove(at : self.blocks.firstIndex(of: block)!)
                }
            }

            if block.x > newBlock.x{
                block.node.run(SKAction.sequence([
                    .moveBy(x: moveRight, y: 0.0, duration: 0.5),
                    garbageCollection]))
            }else{
               block.node.run(SKAction.sequence([
                    .moveBy(x: -moveLeft, y: 0.0, duration: 0.5),
                    garbageCollection]))
            }
        }
    }
}


// Load the SKScene from 'GameScene.sks'
let sceneView = SKView(frame: CGRect(x:0 , y:0, width: 640, height: 480))
sceneView.showsDrawCount = true
sceneView.showsNodeCount = true
sceneView.showsFPS = true
let scene = GameScene(size: sceneView.bounds.size)
// Set the scale mode to scale to fit the window
scene.scaleMode = .aspectFill

// Present the scene
sceneView.presentScene(scene)


PlaygroundSupport.PlaygroundPage.current.liveView = sceneView
