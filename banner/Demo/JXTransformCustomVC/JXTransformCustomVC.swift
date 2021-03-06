//
//  JXTransformCustomVC.swift
//  JXBanner_Example
//
//  Created by Coder_TanJX on 2019/7/30.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit



class JXTransformCustomVC: UIViewController {
    
    var pageCount = 5
    
    lazy var banner: JXBanner = {
        let banner = JXBanner()
        banner.placeholderImgView.image = UIImage(named: "banner_placeholder")
        banner.delegate = self
        banner.dataSource = self
        return banner
        }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(banner)
        banner.snp.makeConstraints {(maker) in
            maker.left.right.equalTo(view)
            maker.height.equalTo(200)
            maker.top.equalTo(view.snp.top).offset(100)
        }

        
    }
    
    deinit {
        print("\(#function) ----------> \(#file.components(separatedBy: "/").last?.components(separatedBy: ".").first ?? #file)")
    }
}

//MARK:- JXBannerDataSource
extension JXTransformCustomVC: JXBannerDataSource {
    
    func banner(_ banner: JXBannerType)
        -> (JXBannerCellRegister) {
            
            return JXBannerCellRegister(type: JXBannerCell.self,
                                        reuseIdentifier: "JXTransformCustomVCCell")
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
                  params: JXBannerParams)
        -> JXBannerParams {
            
            return params.cycleWay(.forward)
    }
    
    func banner(_ banner: JXBannerType,
                  layoutParams: JXBannerLayoutParams)
        -> JXBannerLayoutParams {
            
            return layoutParams
                .layoutType(JXCustomTransform())
                .itemSize(CGSize(width: 300, height: 190))
                .maximumAngle(0.1)
                .itemSpacing(10)
    }
    
    func bannerD(pageControl banner: JXBannerType,
                  numberOfPages: Int,
                  coverView: UIView,
                  builder: JXBannerPageControlBuilder) -> JXBannerPageControlBuilder {
        
        let pageControl = JXPageControlFill()
        pageControl.contentMode = .bottom
        pageControl.activeColor = UIColor.red
        pageControl.columnSpacing = 8
        builder.pageControl = pageControl
        builder.layout = {
            pageControl.snp.makeConstraints { (maker) in
                maker.left.right.equalTo(coverView)
                maker.top.equalTo(coverView.snp.bottom).offset(10)
                maker.height.equalTo(10)
            }
        }
        return builder
        
    }
    
}

//MARK:- JXBannerDelegate
extension JXTransformCustomVC: JXBannerDelegate {
    
    public func banner(_ banner: JXBannerType,
                         didSelectItemAt index: Int) {
        print(index)
    }
}


