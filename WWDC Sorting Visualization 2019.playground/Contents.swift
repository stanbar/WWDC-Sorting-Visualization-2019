//: A SpriteKit based Playground

import PlaygroundSupport
import SpriteKit

struct Block : Comparable, Hashable {
    static func < (left: Block, right: Block) -> Bool {
        return left.area < right.area
    }
    let node : SKShapeNode
    
    init(node : SKShapeNode) {
        self.node = node
    }
    
    var area : CGFloat {
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
    var width : CGFloat {
        return node.frame.width
    }
}


class GameScene: SKScene {
    enum ActionType { case Animation, Comparison, Adjust }
    enum SortType{ case QuickSort, BubbleSort }
    
    let animationDuration = 0.5
    let comparisonDuration = 0.05
    
    private var blockSize : CGSize!
    private var blocks : [Block] = []
    private var blockActions = false
    private var comparistions = 0
    var sortType : SortType = SortType.BubbleSort
    var creatingBlock : Block?
    
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
    
        let comparistionsLabel = SKLabelNode(text: "COMPARISIONS: 0")
        comparistionsLabel.fontName = "AvenirNext-Bold"
        comparistionsLabel.fontSize = 16
    
        comparistionsLabel.name = "comparistions"
        comparistionsLabel.fontColor = NSColor.black
        comparistionsLabel.position = CGPoint(
            x: size.width/2,
            y: size.height/2 - comparistionsLabel.frame.height/2 - 40)
        addChild(comparistionsLabel)
        resetComparisions()
        
        let buttonSort = SortButtonNode()
        buttonSort.name = "sort"
        buttonSort.position = CGPoint(
            x: size.width/2,
            y: size.height - 30)
        buttonSort.delegate = self
        addChild(buttonSort)
        
        let sortingLabel = SKLabelNode(text: "SORTING...")
        sortingLabel.name = "sorting"
        
        sortingLabel.position = CGPoint(
            x: buttonSort.position.x,
            y: buttonSort.position.y - buttonSort.frame.height/2 - 20
        )
        sortingLabel.fontName = "AvenirNext-Bold"
        sortingLabel.fontSize = 10
        sortingLabel.alpha = 0.0
        sortingLabel.fontColor = NSColor.black
        addChild(sortingLabel)
        
        
        let buttonReset = ResetButtonNode()
        buttonReset.name = "reset"
        buttonReset.position = CGPoint(
            x: size.width - buttonReset.frame.width/2 - 10,
            y: size.height - 30)
        buttonReset.delegate = self
        addChild(buttonReset)
        
        let buttonQuickSort = QuickSortButtonNode()
        buttonQuickSort.name = "quick-sort"
        buttonQuickSort.position = CGPoint(
            x: buttonQuickSort.frame.width/2 + 10,
            y: size.height - 30)
        buttonQuickSort.delegate = self
        addChild(buttonQuickSort)
        
        let buttonBubbleSort = BubbleSortButtonNode()
        buttonBubbleSort.name = "bubble-sort"
        buttonBubbleSort.position = CGPoint(
            x: buttonQuickSort.position.x,
            y: buttonSort.position.y - buttonBubbleSort.frame.height/2 - 30)
        buttonBubbleSort.delegate = self
        addChild(buttonBubbleSort)
        
        setSortType(SortType.BubbleSort)
    }
    
    func newBlock(at pos : CGPoint, _ color : NSColor) -> Block{
        let node = SKShapeNode(rectOf: blockSize, cornerRadius : 0.5)
        
        node.position = pos
        node.strokeColor = color
        node.lineWidth = 5
        node.fillColor = color
        node.name = "block"
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
        if(blocks.count <= 1) {return}
        blockActions = true
        let sortingLabel = childNode(withName: "sorting") as! SKLabelNode
        sortingLabel.alpha = 1.0
        let sortNode = childNode(withName: "sort") as! SKSpriteNode
        sortNode.alpha = 0.5
        
        var actions : [(ActionType, Block?, SKAction)] = []
        var positions : [Block?: CGFloat] = [:]
        for block in blocks{
            positions[block] = block.x
        }
        if sortType == SortType.BubbleSort {
            bubblesort(positions: &positions, actions: &actions)
        }else if sortType == SortType.QuickSort {
            quicksort(low: 0, high: blocks.count-1,positions: &positions, actions: &actions)
        }
        
        // Unset semaphore after all actions are executed
        actions.append((ActionType.Animation, actions.last!.1, SKAction.run{
            self.blockActions = false
            sortingLabel.alpha = 0.0
            sortNode.alpha = 1.0
        }))
        
        var duration = 0.0
        var replacedBothOfPair = false
        
        for (type, block, action) in actions{
            block?.node.run(SKAction.sequence([.wait(forDuration: duration), action]))
            
            if type == ActionType.Comparison {
                duration += comparisonDuration
                continue
            }else if type == ActionType.Adjust {
                continue
            }else if replacedBothOfPair{
                duration += animationDuration
            }
            
            replacedBothOfPair = !replacedBothOfPair
        }
        
    }

    public func random(min: Int, max: Int) -> Int {
        assert(min < max)
        return min + Int(arc4random_uniform(UInt32(max - min + 1)))
    }
    
    public func swap<T>(_ a: inout [T], _ i: Int, _ j: Int) {
        if i != j {
            a.swapAt(i, j)
        }
    }
    
    func quicksort(low: Int, high: Int, positions : inout [Block?: CGFloat], actions : inout [(ActionType, Block?, SKAction)]) {
        if low < high {
            let pivotIndex = random(min: low, max: high)
            let (p, q) = partitionDutchFlag(low: low, high: high, pivotIndex: pivotIndex, positions: &positions, actions: &actions)
            quicksort(low: low, high: p - 1, positions: &positions, actions: &actions)
            quicksort(low: q + 1, high: high, positions: &positions, actions: &actions)
        }
    }
    
    func partitionDutchFlag(low: Int, high: Int, pivotIndex: Int, positions : inout [Block?: CGFloat], actions : inout [(ActionType, Block?, SKAction)]) -> (Int, Int) {
        let pivot = blocks[pivotIndex]
        
        var smaller = low
        var equal = low
        var larger = high
        

        while equal <= larger {
            
            if blocks[equal] < pivot {
                highlightComparision(&actions, firstIndex: equal, secondIndex: pivotIndex)
                swap(&blocks, smaller, equal)
                animateSwap(&positions, &actions, firstIndex: smaller, secondIndex: equal)
                smaller += 1
                equal += 1
            } else if blocks[equal] == pivot {
                highlightComparision(&actions, firstIndex: equal, secondIndex: pivotIndex)
                equal += 1
            } else {
                swap(&blocks, equal, larger)
                animateSwap(&positions, &actions, firstIndex: equal, secondIndex: larger)
                larger -= 1
            }
        }
        return (smaller, larger)
    }
    
    func bubblesort(positions : inout [Block?: CGFloat], actions : inout [(ActionType, Block?, SKAction)]){
        for i in 0..<blocks.count {
            for j in 1..<blocks.count - i {
                highlightComparision(&actions, firstIndex: j-1, secondIndex: j)
                if blocks[j] < blocks[j-1] {
                    blocks.swapAt(j, j-1)
                    animateSwap(&positions, &actions, firstIndex: j-1, secondIndex: j)
                }
            }
        }
    }
    
    func highlightComparision(_ actions : inout [(ActionType, Block?, SKAction)], firstIndex i : Int, secondIndex j : Int){
        let currentColor1 = blocks[i].node.fillColor
        let currentColor2 = blocks[j].node.fillColor
        
        let changeColor1 = SKAction.customAction(withDuration: comparisonDuration, actionBlock: { node, elapsedTime in
            if CGFloat(elapsedTime / CGFloat(self.comparisonDuration)) > 0.5 {
                (node as? SKShapeNode)?.strokeColor = currentColor1
            }else{
                (node as? SKShapeNode)?.strokeColor = NSColor.gray
            }
        })
        let changeColor2 = SKAction.customAction(withDuration: comparisonDuration, actionBlock: { node, elapsedTime in
            if CGFloat(elapsedTime / CGFloat(self.comparisonDuration)) > 0.5 {
                (node as? SKShapeNode)?.strokeColor = currentColor2
            }else{
                (node as? SKShapeNode)?.strokeColor = NSColor.gray
            }
        })
        
        actions.append((ActionType.Comparison, blocks[i], changeColor1))
        actions.append((ActionType.Comparison, blocks[j], changeColor2))
        
        actions.append((ActionType.Comparison, blocks[j], SKAction.run {
            let combo = SKLabelNode(text: "+1")
            combo.fontColor = NSColor.black
            combo.fontSize = 14
            combo.position = CGPoint(x: self.blocks[j].x, y: self.blockSize.height + 10)
            
            self.addChild(combo)
            
            combo.run(SKAction.sequence([
                SKAction.wait(forDuration: 1),
                SKAction.moveBy(x: 0, y: 10, duration: 0.5),
                
                SKAction.move(to: self.childNode(withName: "comparistions")!.position, duration: 0.5),
                SKAction.run { self.incComparisions() },
                SKAction.fadeOut(withDuration: 0.5),
                SKAction.run { combo.removeFromParent() }
                ])
            )
        }))
        

    }
    
    func animateSwap(_ positions : inout [Block?: CGFloat], _ actions : inout [(ActionType, Block?, SKAction)], firstIndex: Int, secondIndex: Int){
        
        if secondIndex == firstIndex { return }
        
        let leftIndex = secondIndex > firstIndex ? secondIndex : firstIndex
        let rightIndex = secondIndex > firstIndex ? firstIndex :secondIndex
        
        let leftBlockMin = positions[blocks[leftIndex]]! - blocks[leftIndex].width/2
        let leftBlockMax = positions[blocks[leftIndex]]! + blocks[leftIndex].width/2
        let rightBlockMin = positions[blocks[rightIndex]]! - blocks[rightIndex].width/2
        let rightBlockMax = positions[blocks[rightIndex]]! + blocks[rightIndex].width/2
        
        let distance = rightBlockMin - leftBlockMax
        
        
        positions[blocks[leftIndex]] = rightBlockMax - blocks[leftIndex].width/2
        positions[blocks[rightIndex]] = leftBlockMin + blocks[rightIndex].width/2
        
        let moveBlockBetween = blocks[rightIndex].width - blocks[leftIndex].width
        
        let blocksBetween = blocks[min(leftIndex,rightIndex)+1..<max(rightIndex, leftIndex)]
        
        for block in blocksBetween {
            positions[block] = positions[block]! + moveBlockBetween
            actions.append((ActionType.Adjust, block,
                SKAction.moveTo(x: positions[block]!, duration: comparisonDuration)))
        }

        actions.append((ActionType.Animation, blocks[leftIndex], SKAction.moveTo(x: positions[blocks[leftIndex]]!, duration: animationDuration)))
        actions.append((ActionType.Animation, blocks[rightIndex],
                        SKAction.sequence([SKAction.moveTo(x: positions[blocks[rightIndex]]!, duration: animationDuration),
                            SKAction.playSoundFileNamed("swap_sound2.wav", waitForCompletion: false)])
                        ))
    }
    
    override func mouseDown(with event: NSEvent) {
        startNewBlockCreation(atPoint : event.location(in: self))
    }
    
    override func mouseDragged(with event: NSEvent) {
        moveNewBlockCreation(atPoint : event.location(in: self))
    }
    
    override func mouseUp(with event: NSEvent) {
        endNewBlockCreation(atPoint : event.location(in: self))
    }
    
    func startNewBlockCreation(atPoint pos : CGPoint) {
        if blockActions {
            print("Can not add new block right now")
            return
        }
        blockActions = true
        
        let creatingBlock = newBlock(at : pos,
                                    SKColor(red: CGFloat.random(in: 0.3...1.0),
                                            green: CGFloat.random(in: 0.3...1.0),
                                            blue: CGFloat.random(in: 0.3...1.0),
                                            alpha: CGFloat.random(in: 0.9...1.0)))
        creatingBlock.node.run(
            .repeatForever(
            .sequence([.scale(by: 0.5, duration: 1),
                       .scale(by: 2.0, duration: 1)])))
        
        
        addChild(creatingBlock.node)
        self.creatingBlock = creatingBlock
    }

    
    func moveNewBlockCreation(atPoint pos : CGPoint){
        guard let creatingBlock = self.creatingBlock as Block? else { return }
        creatingBlock.node.position = pos
    }

    
    func endNewBlockCreation(atPoint pos : CGPoint){
        guard let creatingBlock = self.creatingBlock as Block? else { return }
        creatingBlock.node.removeAllActions()
        creatingBlock.node.position = pos
        let insertIndex = findInsertIndex(for: pos)
        blocks.insert(creatingBlock, at: insertIndex)
        makeSpace(for: creatingBlock, at: insertIndex)
        creatingBlock.node.run(SKAction.sequence([
            .moveTo(y: creatingBlock.node.frame.height/2, duration: 0.5),
            SKAction.playSoundFileNamed("landing2.wav", waitForCompletion: false),
            .run{ self.blockActions = false }
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
    
    func makeSpace(for newBlock : Block, at insertIndex : Int){
        var positions : [Block: CGFloat] = [:]
        for block in blocks{
            positions[block] = block.x
        }
        
        //iterate to left of me
        for i in stride(from: insertIndex, to: 0, by: -1){
            let leftBlock = self.blocks[i-1]
            let rightBlock = self.blocks[i]
            
            if left(positions[rightBlock]!, rightBlock) < right(positions[leftBlock]!, leftBlock) {
                    let moveLeft = right(positions[leftBlock]!, leftBlock) - left(positions[rightBlock]!, rightBlock)
                    positions[leftBlock] = positions[leftBlock]! - moveLeft
                    leftBlock.node.run(SKAction.sequence([
                        .moveTo(x: positions[leftBlock]!, duration: animationDuration),
                        garbageCollector(for:leftBlock)]))
            }
        }
        
        //iterate to right of me
        for i in insertIndex+1..<blocks.count{
            let leftBlock = self.blocks[i-1]
            let rightBlock = self.blocks[i]
        
            if right(positions[leftBlock]!, leftBlock) > left(positions[rightBlock]!, rightBlock) {
                let moveRight = right(positions[leftBlock]!, leftBlock) -  left(positions[rightBlock]!, rightBlock)
                positions[rightBlock] = positions[rightBlock]! + moveRight
                rightBlock.node.run(SKAction.sequence([
                    .moveTo(x: positions[rightBlock]!, duration: animationDuration),
                    garbageCollector(for:rightBlock)]))
            }
            
            
        }
    }
    func left(_ pos : CGFloat, _ block :  Block) -> CGFloat {
        return pos - block.width/2
    }

    func right(_ pos : CGFloat, _ block :  Block) -> CGFloat {
        return pos + block.width/2
    }
    
    func garbageCollector(for block : Block)->SKAction{
        return SKAction.run {
            if block.right < 0.0 || block.left > self.size.width {
                block.node.removeFromParent()
                self.blocks.remove(at : self.blocks.firstIndex(of: block)!)
            }
        }
    }
    func setSortType(_ sortType : SortType){
        self.sortType = sortType
        let btnBubbleSort = childNode(withName: "bubble-sort") as! BubbleSortButtonNode
        let btnQuickSort = childNode(withName: "quick-sort") as! QuickSortButtonNode
        if(sortType == SortType.BubbleSort){
            btnBubbleSort.select(true)
            btnQuickSort.select(false)
        }else{
            btnBubbleSort.select(false)
            btnQuickSort.select(true)
        }
    }
    
    func resetComparisions(){
        comparistions = 0
        let label = childNode(withName: "comparistions") as! SKLabelNode
        label.text = "COMPARISIONS: \(comparistions)"
    }
    func incComparisions(){
        comparistions = comparistions + 1
        let label = childNode(withName: "comparistions") as! SKLabelNode
        label.run(SKAction.sequence([
            .scale(by: 1.2, duration: 0.1),
            .run{ label.text = "COMPARISIONS: \(self.comparistions)"},
            .playSoundFileNamed("combo.wav", waitForCompletion: false),
            .scale(by: CGFloat(1.0 / 1.2), duration: 0.1),
            ]))
    }
    
    func reset(_ block : () -> Void){
        self.resetComparisions()
        self.blockActions = false
        block()
    }
}
// MARK: ResetButtonNodeDelegate

extension GameScene: ResetButtonNodeDelegate {
    
    func didTapReset(sender: ResetButtonNode) {
        if blockActions { return }
        reset {
            enumerateChildNodes(withName: "block") { (node, stop) in
                let fadeOutAction = SKAction.fadeOut(withDuration: 0.25)
                fadeOutAction.timingMode = .easeInEaseOut
                node.run(fadeOutAction, completion: {
                    node.removeFromParent()
                })
            }
            self.blocks = []
        }
    }
}
extension GameScene: SortButtonNodeDelegate {
    func didTapSort(sender: SortButtonNode) {
        resetComparisions()
        sort()
    }
}
extension GameScene: QuickSortButtonNodeDelegate {
    func didTapSortType(sender: QuickSortButtonNode) {
        setSortType(SortType.QuickSort)
    }
}
extension GameScene: BubbleSortButtonNodeDelegate {
    func didTapSortType(sender: BubbleSortButtonNode) {
        setSortType(SortType.BubbleSort)
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
