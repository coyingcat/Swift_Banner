//
//  JXBanner.swift
//  JXBanner_Example
//
//  Created by Coder_TanJX on 2019/6/6.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit

// MARK: - JXBannerType
public class JXBanner: JXBaseBanner, JXBannerType {
    
    public var indentify: String? = "JXBaseBanner"
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupBase()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupBase()
    }
    
    private func setupBase() {
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    public weak var dataSource: JXBannerDataSource? { didSet { reloadView() }}
    
    public weak var delegate: JXBannerDelegate?
    
    /// Outside of pageControl
    internal var pageControl_D: (UIView & JXPageControlType)?
    
    override func setCurrentIndex() {
        
        let currentPage = indexOfIndexPath(currentIndexPath)
        pageControl_D?.currentPage = currentPage
        delegate?.banner(self, center: currentPage)

        if let cell = collectionView.cellForItem(at: currentIndexPath) {
            dataSource?.banner(self,
                                 lastCenterIndex: lastCenterIndex,
                                 lastCenterCell: lastIndexPathCell)
            dataSource?.banner(self,
                                 centerIndex: currentPage,
                                 centerCell: cell)
            lastCenterIndex = currentPage
            lastIndexPathCell = cell
        }
    }

    /// The refresh UI, get data from
    public func reloadView() {
        
        // Stop Animation
        stop()
        
        // refresh
        refreshDataSource()
        refreshDelegate()
        refreshData()
        
        // Start Animation
        start()
    }
}

// MARK: - Private mothod
extension JXBanner {
    
    private func refreshDataSource() {
        
        // DataSource
        if let _ = dataSource?.banner(numberOfItems: self),
            let tempDataSource = dataSource {
            
            // Register cell
            if let register = dataSource?.banner(self) {
                
                if let nib = register.nib {
                    collectionView.register(
                        nib,
                        forCellWithReuseIdentifier: register.reuseIdentifier)
                }else {
                    collectionView.register(
                    register.type,
                    forCellWithReuseIdentifier: register.reuseIdentifier)
                    if register.type == nil {
                        print(" ------JXBanner:   When you are not using the nib cell file, ")
                        print(" ------you must set the JXBannerCellRegister-> type to the cell class!! ---------------------")
                    }
                }
                
                cellRegister = register
            }
            
            // numberOfItems
            pageCount = tempDataSource.banner(numberOfItems: self)
            
            // params
            params = dataSource?.banner(self,
                                          params: params) ?? params
        
            collectionView.contentInset = params.contentInset
            
            // layoutParams
            layout.params = tempDataSource.banner(self,
                                                    layoutParams: layout.params!)
            
            // PageControl
            refreshPageControl()
        }
    }
    
    
    private func refreshPageControl() {
        self.pageControl_D?.removeFromSuperview()
        self.pageControl_D = nil
      
            let pBuilder = dataSource?.bannerD(pageControl: self,
                                                numberOfPages: pageCount,
                                                coverView: coverView,
                                                builder: JXBannerPageControlBuilder())
            if let tempPageControl = pBuilder?.pageControl{
                pageControl_D = tempPageControl
                pageControl_D?.numberOfPages = pageCount
                coverView.addSubview(tempPageControl)
            }
            if let layout = pBuilder?.layout {
                layout()
            }
        
    }
    
    private func refreshDelegate() {
        // Dalegate
        if let tempDelegate = delegate {
            tempDelegate.banner(self, coverView: coverView)
        }
    }
    
    private func refreshData() {
        
        if let cell = lastIndexPathCell {
            dataSource?.banner(self,
                                 lastCenterIndex: lastCenterIndex,
                                 lastCenterCell: cell)
            lastCenterIndex = nil
            lastIndexPathCell = nil
        }
        
        // Reinitialize data
        params.currentRollingDirection = .right
        collectionView.setCollectionViewLayout(layout, animated: true)
        collectionView.bounces = params.isBounces
        collectionView.reloadData()
        if pageCount == 1,
            params.cycleWay == .forward {
            params.cycleWay = .skipEnd
        }
        placeholderImgView.isHidden = pageCount > 0
        reinitializeIndexPath()
    }
    
    /// Reload current indexpath
    private func reinitializeIndexPath() {
        
        var tempIndexPath = IndexPath(row: 0, section: 0)
        if pageCount > 0,
            params.cycleWay == .forward {
            // Take the middle group and show it
            tempIndexPath = IndexPath(row: (kMultiplier * pageCount / 2),
                                         section: 0)
        }

        if pageCount > 0 {
            scrollToIndexPath(tempIndexPath, animated: false)
        }
        
        collectionView.layoutIfNeeded()
        currentIndexPath = tempIndexPath
    }

    @objc internal override func autoScroll() {

        // Determine if it's on screen
        guard isShowingOnWindow() != false,
            pageCount > 1 else { return }
        
        switch params.cycleWay {
            
        case .forward:
            
            currentIndexPath = currentIndexPath + 1
            scrollToIndexPath(currentIndexPath,
                              animated: true)
        case .skipEnd:
            
            if currentIndexPath.row == pageCount - 1 {
                currentIndexPath = IndexPath(row: 0, section: 0)
                
                scrollToIndexPath(currentIndexPath, animated: false)
                scrollViewDidEndScrollingAnimation(collectionView)
                if let transitionType = params.edgeTransitionType?.rawValue {
                    let transition = CATransition()
                    transition.duration = CFTimeInterval(0.3)
                    transition.subtype = params.edgeTransitionSubtype
                    transition.type = CATransitionType(rawValue: transitionType)
                    transition.isRemovedOnCompletion = true
                    collectionView.layer.add(transition, forKey: nil)
                }
                
            } else {
                currentIndexPath = currentIndexPath + 1
                scrollToIndexPath(currentIndexPath, animated: true)
            }
        
        case .rollingBack:

            
            switch params.currentRollingDirection {
                
            case .right:
                
                if currentIndexPath.row == pageCount - 1 {
                    currentIndexPath = currentIndexPath - 1
                    params.currentRollingDirection = .left
                }else {
                    currentIndexPath = currentIndexPath + 1
                }
                scrollToIndexPath(currentIndexPath, animated: true)
                
            case .left:
                
                if currentIndexPath.row == 0 {
                    currentIndexPath = currentIndexPath + 1
                    params.currentRollingDirection = .right
                }else {
                    currentIndexPath = currentIndexPath - 1
                }
                scrollToIndexPath(currentIndexPath, animated: true)
            }
        }
    }
    
    /// UICollectionCell rolling error detection
    private func indexPathErrorDetection() {
        let indexPaths = collectionView.indexPathsForVisibleItems
        var attriArr = [UICollectionViewLayoutAttributes?]()
        for indexPath in indexPaths {
            let attri = collectionView.layoutAttributesForItem(at: indexPath)
            attriArr.append(attri)
        }
        let centerX: CGFloat = collectionView.contentOffset.x + collectionView.frame.width * 0.5
        var minSpace = CGFloat(MAXFLOAT)
        var shouldSet = true
        if layout.params?.layoutType != nil && indexPaths.count <= 2 {
            shouldSet = false
        }
        
        var tempIndexPath: IndexPath?
        for atr in attriArr {
            if let obj = atr, shouldSet {
                obj.zIndex = 0;
                if(abs(minSpace) > abs(obj.center.x - centerX)) {
                    minSpace = obj.center.x - centerX;
                    tempIndexPath = obj.indexPath;
                }
            }
        }
        // currentIndexPath != tempIndexPath : To mask multiple calls to currentIndexPath's didSet method
        if currentIndexPath != tempIndexPath,
            let indexPath = tempIndexPath {
            currentIndexPath = indexPath
        }
        scrollToIndexPath(currentIndexPath, animated: true)
    }
}

// MARK: - UIScrollViewDelegate
extension JXBanner {
    
    /// Began to drag and drop
    public func scrollViewWillBeginDragging(
        _ scrollView: UIScrollView) { pause() }
    
    /// The drag is about to end
    public func scrollViewWillEndDragging(
        _ scrollView: UIScrollView,
        withVelocity velocity: CGPoint,
        targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        pause()
        
        if params.cycleWay != .forward {
            
            if velocity.x >= 0 ,
                currentIndexPath.row == pageCount - 1 {
                scrollToIndexPath(currentIndexPath, animated: true)
                return
                
            }
            
            if velocity.x <= 0 ,
                currentIndexPath.row == 0 {
                scrollToIndexPath(currentIndexPath, animated: true)
                return
                
            }
        }
        
        if velocity.x > 0 {
            // Slide left. Next slide
            currentIndexPath = currentIndexPath + 1
        }else if velocity.x < 0 {
            // Slide right. Go ahead
            currentIndexPath = currentIndexPath - 1
        }else {
            // Error detection
            indexPathErrorDetection()
        }
    }
    
    /// It's going to start slowing down
    public  func scrollViewWillBeginDecelerating(
        _ scrollView: UIScrollView) {
        scrollToIndexPath(currentIndexPath,
                          animated: true)
    }
    
    /// End to slow down
    public func scrollViewDidEndDecelerating(
        _ scrollView: UIScrollView) {}
    
    /// Scroll animation complete
    public func scrollViewDidEndScrollingAnimation(
        _ scrollView: UIScrollView) {
        start()
    }
    
    /// Rolling in the
    public func scrollViewDidScroll(
        _ scrollView: UIScrollView) {}
}

// MARK:- UICollectionViewDataSource, UICollectionViewDelegate
extension JXBanner:
    UICollectionViewDataSource,
UICollectionViewDelegate {
    
    public func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int)
        -> Int {
            return params.cycleWay == .forward ? kMultiplier * pageCount : pageCount
    }
    
    public func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath)
        -> UICollectionViewCell {
            
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: cellRegister.reuseIdentifier,
                for: indexPath)
            return dataSource?.banner(self,
                                        cellForItemAt: indexOfIndexPath(indexPath),
                                        cell: cell) ?? cell
    }
    
    
    public func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        delegate?.banner(self,
                           didSelectItemAt: indexOfIndexPath(indexPath))
        indexPathErrorDetection()
    }
    
    func indexOfIndexPath(_ indexPath : IndexPath)
        -> Int {
            return pageCount > 0 ? Int(indexPath.item % pageCount) : 0
    }
}
