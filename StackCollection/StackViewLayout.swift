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
    private var attributeArray: [UICollectionViewLayoutAttributes] = []
    override var collectionViewContentSize: CGSize {
        return collection.bounds.size
    }
    
    override func prepare() {
        guard let delegate = collection.delegate as? StackViewDelegateLayout else { return }
        guard attributeArray.isEmpty || collection.numberOfItems(inSection: 0) != attributeArray.count else { return }
        let visiableRect = CGRect(origin: collection.contentOffset, size: collection.bounds.size)
        let center = CGPoint(x: visiableRect.midX, y: visiableRect.midY)
        attributeArray = [Int](0..<collection.numberOfItems(inSection: 0)).map({ (item) -> UICollectionViewLayoutAttributes in
            let index = IndexPath(item: item, section: 0)
            let attrs = UICollectionViewLayoutAttributes(forCellWith: index)
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
    
    func applyUpdate(for vector: CGPoint, at index: IndexPath) {
        guard let attr = self.layoutAttributesForItem(at: index) else { fatalError("Moving unexist item")}
        let original = CGAffineTransform.identity
        let translatedTransform = original.translatedBy(x: vector.x, y: 0)
        let angle = atan(vector.x * 2.0 / collection.bounds.height).truncatingRemainder(dividingBy: CGFloat.pi)
        let rotateTransform = original.rotated(by: angle)
        attr.transform = translatedTransform.concatenating(rotateTransform)
        if let secondIndex = attributeArray.index(where:{$0.indexPath.item == index.item + 1}) {
            let secAttr = attributeArray[secondIndex]
            secAttr.alpha = fabs(angle) * 4.0 / CGFloat.pi
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
            layout.applyUpdate(for: guesture.translation(in: self), at:topIndex)
            break
        case .cancelled, .ended, .failed:
            layout.removeUpdate()
            break
        default:
            break
        }
    }
}
