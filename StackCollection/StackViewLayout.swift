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
            attrs.transform = CGAffineTransform.identity.translatedBy(x: CGFloat(item * 2), y: 0)
            attrs.zIndex = collection.numberOfItems(inSection: 0) - item - 1
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
    
    override func layoutAttributesForInteractivelyMovingItem(at indexPath: IndexPath, withTargetPosition position: CGPoint) -> UICollectionViewLayoutAttributes {
        guard let attr = self.layoutAttributesForItem(at: indexPath) else { fatalError("Moving unexist item")}
        attr.center.x = position.x
        return attr
    }
}
