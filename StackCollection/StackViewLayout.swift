//
//  StackViewLayout.swift
//  StackCollection
//
//  Created by Xinyuan's on 4/6/18.
//  Copyright © 2018 Xinyuan Wang. All rights reserved.
//

import UIKit

protocol StackViewDelegateLayout: UICollectionViewDelegate {
    func collectionView(_ collection: UICollectionView, layout: StackViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    func collectionView(_ collection: UICollectionView, shouldPopFor layout: StackViewLayout) -> Bool
}
class StackViewLayoutAttributes: UICollectionViewLayoutAttributes {
    var translation: CGPoint = CGPoint(x: 0, y: 0)
    var angle: CGFloat = 0 {
        didSet {
            guard angle < CGFloat.pi && angle > -CGFloat.pi else { return }
            let translationTransform = CGAffineTransform.identity.translatedBy(x: translation.x, y: translation.y)
            let rotationTransform = CGAffineTransform.identity.rotated(by: angle)
            self.transform = translationTransform.concatenating(rotationTransform)
        }
    }
}

class StackViewLayout: UICollectionViewLayout {
    
    var itemSize: CGSize = .zero
    var topIndexPath: IndexPath? {
        return attributeArray.first?.indexPath
    }
    
    private var collection: UICollectionView {
        guard let col = collectionView else {
            fatalError("\(String(describing: self)) must attach to a collectionView")
        }
        return col
    }
    
    private var attributeArray: [StackViewLayoutAttributes] = []
    
    override var collectionViewContentSize: CGSize {
        return collection.bounds.size
    }
    
    override class var layoutAttributesClass: AnyClass {
        return StackViewLayoutAttributes.self
    }
    
    override func prepare() {
        guard let delegate = collection.delegate as? StackViewDelegateLayout else { return }
        guard attributeArray.isEmpty || collection.numberOfItems(inSection: 0) != attributeArray.count else { return }
        let visiableRect = CGRect(origin: collection.contentOffset, size: collection.bounds.size)
        let center = CGPoint(x: visiableRect.midX, y: visiableRect.midY)
        attributeArray = [Int](0..<collection.numberOfItems(inSection: 0)).map({ (item) -> StackViewLayoutAttributes in
            let index = IndexPath(item: item, section: 0)
            let attrs = StackViewLayoutAttributes(forCellWith: index)
            attrs.size = delegate.collectionView(collection, layout: self, sizeForItemAt: index)
            attrs.center = center
            attrs.zIndex = collection.numberOfItems(inSection: 0) - item - 1
            attrs.alpha = item == 0 ? 1 : 0
            return attrs
        })
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return attributeArray
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard let index = attributeArray.index(where: {$0.indexPath == indexPath}) else { return nil }
        return attributeArray[index]
    }
    
    override func finalLayoutAttributesForDisappearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard let attrs = layoutAttributesForItem(at: itemIndexPath)?.copy() as? StackViewLayoutAttributes else { return nil }
        attrs.translation = CGPoint(x: attrs.translation.x + 100, y: attrs.translation.y)
        attrs.angle = attrs.angle > 0 ? CGFloat.pi / 2.0 : -CGFloat.pi / 2.0
        return attrs
    }
}

//MARK: Public method
extension StackViewLayout {
    func applyUpdate(for vector: CGPoint, at index: IndexPath) {
        guard let attr = self.layoutAttributesForItem(at: index) as? StackViewLayoutAttributes else { fatalError("Moving unexist item")}
        attr.translation = vector
        attr.angle = atan(vector.x * 2.0 / collection.bounds.height).truncatingRemainder(dividingBy: CGFloat.pi)
        if let secondIndex = attributeArray.index(where:{$0.indexPath.item == index.item + 1}) {
            let secAttr = attributeArray[secondIndex]
            secAttr.alpha = fabs(attr.angle) * 4.0 / CGFloat.pi
        }
        invalidateLayout()
    }
    
    func removeUpdate() {
        for attr in attributeArray {
            attr.transform = CGAffineTransform.identity
        }
        invalidateLayout()
    }
}

extension UICollectionView {
    @objc func handlePan(_ guesture: UIPanGestureRecognizer) {
        guard let layout = self.collectionViewLayout as? StackViewLayout, let topIndex = layout.topIndexPath else { return }
        guard let cell = cellForItem(at: topIndex) else { return }
        let pos = guesture.location(in: cell)
        guard pos.x >= 0 && pos.x <= cell.bounds.height && pos.y >= 0 && pos.y <= cell.bounds.height else { return }
        switch guesture.state {
        case .began, .changed:
            layout.applyUpdate(for: CGPoint(x:guesture.translation(in: self).x, y: 0), at:topIndex)
            break
        case .cancelled, .ended, .failed:
            if let del = delegate as? StackViewDelegateLayout, del.collectionView(self, shouldPopFor: layout) {
                performBatchUpdates({
                    self.deleteItems(at: [topIndex])
                }, completion: { (finished) in
                    guard finished else { return }
                    self.reloadData()
                })
            }else {
                layout.removeUpdate()
            }
            break
        default:
            break
        }
    }
}
