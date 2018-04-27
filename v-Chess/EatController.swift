//
//  EatController.swift
//  v-Chess
//
//  Created by Сергей Сейтов on 20.03.17.
//  Copyright © 2017 V-Channel. All rights reserved.
//

import UIKit

class EatController: UICollectionViewController, UICollectionViewDelegateFlowLayout {

    var figures:[UIImageView] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.setupBorder(UIColor.white, radius: 5, width: 2)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        collectionView?.reloadData()
    }
    
    @objc func eat(_ figure:UIImageView) {
        figures.append(figure)
        collectionView?.reloadData()
    }
    
    @objc func retrive() -> UIImageView? {
        let figure = figures.last
        figures.removeLast()
        collectionView?.reloadData()
        return figure
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { (context: UIViewControllerTransitionCoordinatorContext) in
        }) { (context: UIViewControllerTransitionCoordinatorContext) in
            self.collectionView?.reloadData()
        }
    }
    
    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return figures.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "figure", for: indexPath) as! EatCell
        cell.figureView.image = figures[indexPath.row].image
        return cell
    }

    // MARK: UICollectionViewDelegate

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if self.collectionView!.frame.width > self.collectionView!.frame.height {
            let width = self.collectionView!.frame.width / 8
            let height = self.collectionView!.frame.height / 2
            return CGSize(width: width, height: height)
        } else {
            let width = self.collectionView!.frame.width / 2
            let height = self.collectionView!.frame.height / 8
            return CGSize(width: width, height: height)
        }
    }
}
