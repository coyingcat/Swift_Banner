//
//  DefaultVC.swift
//  JXBanner_Example
//
//  Created by Coder_TanJX on 2019/7/30.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit


class DefaultVC: UIViewController {
    
    var pageCount = 5

    @IBOutlet weak var banner: JXBanner!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        banner.placeholderImgView.image = UIImage(named: "banner_placeholder")
        banner.delegate = self
        banner.dataSource = self
        

    }
    
    deinit {
        print("\(#function) ----------> \(#file.components(separatedBy: "/").last?.components(separatedBy: ".").first ?? #file)")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        banner.reloadView()
    }
}

//MARK:- JXBannerDataSource
extension DefaultVC: JXBannerDataSource {
    
    func banner(_ banner: JXBannerType)
        -> (JXBannerCellRegister) {
            return JXBannerCellRegister(type: JXBannerCell.self,
                                        reuseIdentifier: "JXDefaultVCCell")
    }
    
    func banner(numberOfItems banner: JXBannerType)
        -> Int { return pageCount }
    
    func banner(_ banner: JXBannerType,
                  cellForItemAt index: Int,
                  cell: UICollectionViewCell)
        -> UICollectionViewCell {
            let tempCell = cell as! JXBannerCell
            tempCell.layer.cornerRadius = 8
            tempCell.layer.masksToBounds = true
            tempCell.imageView.image = UIImage(named: "\(index).jpg")
            
            return tempCell
    }
    
    func banner(_ banner: JXBannerType,
                  layoutParams: JXBannerLayoutParams)
        -> JXBannerLayoutParams {
        return layoutParams
            .itemSize(CGSize(width: 300, height: 150))
            .itemSpacing(20)
    }
    
}

//MARK:- JXBannerDelegate
extension DefaultVC: JXBannerDelegate {
    
    public func banner(_ banner: JXBannerType,
                         didSelectItemAt index: Int) {
        print(index)
    }
    
    func banner(_ banner: JXBannerType, center index: Int) {
        print(index)
    }
    
    
    
}
