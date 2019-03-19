//: A SpriteKit based Playground

import PlaygroundSupport
import SpriteKit

class GameScene: SKScene {
    
    private var spinnyNode : SKShapeNode!
    private var areaNode : SKLabelNode!
    
    override func didMove(to view: SKView) {
        physicsWorld.gravity = CGVector.zero
        backgroundColor = SKColor.white
        
        // Create shape node to use during mouse interaction
        let w = (size.width + size.height) * 0.05
        
        spinnyNode = SKShapeNode(rectOf: CGSize(width: w, height: w))
        spinnyNode.lineWidth = 2.5
        
    }
    
    @objc static override var supportsSecureCoding: Bool {
        // SKNode conforms to NSSecureCoding, so any subclass going
        // through the decoding process must support secure coding
        get {
            return true
        }
    }
    
    var newBlock : SKShapeNode?
    
    func touchDown(atPoint pos : CGPoint) {
        let newBlock = startNewBlockCreation(atPoint : pos)
        addChild(newBlock)
    }
    
    func startNewBlockCreation(atPoint pos : CGPoint) -> SKShapeNode{
        let newBlock = spinnyNode.copy() as! SKShapeNode
        newBlock.position = pos
        newBlock.strokeColor = SKColor(red: CGFloat.random(in: 0.3...1.0),
                                       green: CGFloat.random(in: 0.3...1.0),
                                       blue: CGFloat.random(in: 0.3...1.0),
                                       alpha: CGFloat.random(in: 0.9...1.0))
        newBlock.fillColor = newBlock.strokeColor
        newBlock.run(
            .repeatForever(
            .sequence([.scale(by: 0.5, duration: 1),
                       .scale(by: 2.0, duration: 1)])))
        
        self.newBlock = newBlock
        return newBlock
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        moveNewBlockCreation(atPoint : pos)
        
    }
    
    func moveNewBlockCreation(atPoint pos : CGPoint){
        guard let newBlock = self.newBlock as SKShapeNode? else { return }
        newBlock.position = pos
    }
    
    func touchUp(atPoint pos : CGPoint) {
        endNewBlockCreation(atPoint : pos)
        
    }
    
    func endNewBlockCreation(atPoint pos : CGPoint){
        guard let newBlock = self.newBlock as SKShapeNode? else { return }
        newBlock.removeAllActions()
        newBlock.position = pos
        makeSpace(for: newBlock)
        newBlock.run(SKAction.moveTo(y: newBlock.frame.height/2, duration: 0.5))
        self.newBlock = nil
    }
    
    func left(_ node : SKNode) -> CGFloat{
        return node.frame.minX
    }
    func right(_ node : SKNode) -> CGFloat{
        return node.frame.maxX
    }
    
    var counter : Int = 0
    func makeSpace(for newBlock : SKShapeNode){
        // find matching
        var moveLeft : CGFloat = 0.0
        var moveRight : CGFloat = 0.0
        for child in children{
            if(child == newBlock){continue}
            var willCollide = false
            print("Checking [\(left(child)) \(right(child))]")
            if left(newBlock) == right(child) && //   [new]
                left(newBlock) == right(child){ //    [old]
                willCollide = true
                print("Collistion detected")
                print("[new]")
                print("[old]")
            }
            if left(newBlock) >= left(child) &&
                left(newBlock) <= right(child) &&
                right(newBlock) >= right(child){
                willCollide = true
                print("Collision detected")
                print("   [new]")
                print("[old]")
            }
            if left(newBlock) <= left(child) && //  [new]
                right(newBlock) >= left(child) && //     <>
                right(newBlock) <= right(child){ //     [old]
                willCollide = true
                print("Collision detected")
                print("[new]")
                print("   [old]")
            }
            if left(newBlock) >= left(child) && //  [new]
                right(newBlock) <= right(child) { // [ old ]
                willCollide = true
                print("Collision detected")
                print("  [new]")
                print("[  old  ]")
            }
            
            if left(newBlock) <= left(child) && //  [ new ]
                right(newBlock) >= right(child){ //     [old]
                willCollide = true
                print("Collision detected")
                print("[  new  ]")
                print("  [old]")
            }
            if !willCollide {continue}
            counter = counter + 1
                
            print("\(counter)will collide")
            if newBlock.position.x >= child.position.x && newBlock.frame.minX < child.frame.maxX{
                //    [new]
                //    <>
                // [old]
                moveLeft = child.frame.maxX - newBlock.frame.minX
            }else if newBlock.position.x < child.position.x && newBlock.frame.maxX > child.frame.minX{
                //  [new]
                //    <>
                //   [old]
                moveRight = newBlock.frame.maxX - child.frame.minX
            }
        }
            
        for child in children{
            if(child == newBlock){continue}
            let garbageCollection = SKAction.run {
                print("Check if remove child.frame.maxX: \(child.frame.maxX)",
                    "child.frame.minX: \(child.frame.minX)",
                    "self.size.width: \(self.size.width)"
                )
                
                if child.frame.maxX < 0.0
                    || child.frame.minX > self.size.width {
                    child.removeFromParent()
                }
            }

            if child.position.x > newBlock.position.x{
                child.run(SKAction.sequence([
                    .moveBy(x: moveRight, y: 0.0, duration: 0.5),
                    garbageCollection]))
            }else{
               child.run(SKAction.sequence([
                .moveBy(x: -moveLeft, y: 0.0, duration: 0.5),
                garbageCollection]))
            }
            
        }
    }
    
    func sort(){
        if children.count < 2 { return }
        for _ in 0...children.count {
            for value in 1...children.count - 1 {
                if area(children[value-1]) > area(children[value]) {
                    replace(children[value-1], children[value])
                }
            }
        }
    }
    func area(_ node : SKNode) -> CGFloat{
        return node.frame.width * node.frame.height
    }
    
    func replace(_ first : SKNode, _ second : SKNode){
        let firstReplace = SKAction.sequence([
            .wait(forDuration: 0.5),
            .move(to: second.position, duration: 0.5)])
        
        let secondReplace = SKAction.sequence([
            .wait(forDuration: 0.5),
            .move(to: first.position, duration: 0.5)])
        second.run(secondReplace)
        first.run(firstReplace)
        
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
