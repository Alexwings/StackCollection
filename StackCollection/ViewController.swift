//
//  ViewController.swift
//  StackCollection
//
//  Created by Xinyuan's on 4/6/18.
//  Copyright © 2018 Xinyuan Wang. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    let collectionView: UICollectionView = {
        let layout = StackViewLayout()
        let col = UICollectionView(frame: .zero, collectionViewLayout: layout)
        return col
    }()
    let cellID = "CellID"
    
    var cardCollection: [UIColor] = [.blue, .black, .brown, .cyan, .gray, .green, .red, .yellow]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(collectionView)
        collectionView.attachEdgeTo(top: (view.safeAreaLayoutGuide.topAnchor, 0), bottom: (view.safeAreaLayoutGuide.bottomAnchor, 0), leading: (view.safeAreaLayoutGuide.leadingAnchor, 0), trailing: (view.safeAreaLayoutGuide.trailingAnchor, 0))
        collectionView.backgroundColor = .white
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: cellID)
        collectionView.dataSource = self
        collectionView.delegate = self
        let pan = UIPanGestureRecognizer(target: collectionView, action: #selector(collectionView.handlePan(_:)))
        pan.maximumNumberOfTouches = 1
        pan.minimumNumberOfTouches = 1
        collectionView.addGestureRecognizer(pan)
    }
}

extension ViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cardCollection.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath)
        cell.backgroundColor = cardCollection[indexPath.row]
        return cell
    }
}

extension ViewController: UICollectionViewDelegate {
    
}

extension ViewController: StackViewDelegateLayout {
    
    func collectionView(_ collection: UICollectionView, shouldPopFor layout: StackViewLayout) -> Bool {
        guard let topIndex = layout.topIndexPath else { return false }
        guard let attr = layout.layoutAttributesForItem(at: topIndex) as? StackViewLayoutAttributes else { return false }
        let result = attr.angle >= CGFloat.pi / 6.0 || attr.angle <= -CGFloat.pi / 6.0
        if result {
            cardCollection.removeFirst()
        }
        return result
    }
    
    func collectionView(_ collection: UICollectionView, layout: StackViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = view.bounds.width * 2 / 3
        let height = (3.0 / 2.0) * width
        return CGSize(width: width, height: height)
    }
}
