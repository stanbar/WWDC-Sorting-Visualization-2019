import Foundation
import SpriteKit

public class SortButtonNode: SKSpriteNode {
    
    // MARK: Properties
    
    public weak var delegate: SortButtonNodeDelegate?
    
    // MARK: Lifecycle
    
    public init() {
        let texture = SKTexture(imageNamed: "sort-button")
        let color = SKColor.red
        let size = CGSize(width: 135, height: 50)
        
        super.init(texture: texture, color: color, size: size)

        isUserInteractionEnabled = true
        zPosition = 1
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Touch Handling

    public override func mouseUp(with event: NSEvent) {
        let location = event.location(in: self)
        if location.isInside(node: self) {
            // Touch Up Inside
            delegate?.didTapSort(sender: self)
        }
    }
}

// MARK: CGPoint Extension for Hit Testing

public extension CGPoint {
    
    func isInside(node: SKSpriteNode) -> Bool {
        if self.x > -node.size.width/2, self.x < node.size.width/2, self.y > -node.size.height/2, self.y < node.size.height/2 { return true }
        return false
    }
}

// MARK: ResetButtonNodeDelegate

public protocol SortButtonNodeDelegate: class {
    func didTapSort(sender: SortButtonNode)
}
