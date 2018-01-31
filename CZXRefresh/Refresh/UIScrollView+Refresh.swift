//
//  UIScrollView+PAF.swift
//  CZXRefresh
//
//  Created by 陈主昕 on 2018/1/27.
//  Copyright © 2018年 average. All rights reserved.
//

import UIKit

extension UIScrollView {
    
    /// 下拉刷新手势
    public var czx_headerView: RefreshHeaderView? {
        get {
            return self.viewWithTag(headerTag) as? RefreshHeaderView
        }
        
        set {
            if let header = newValue {
                header.tag = headerTag
                self.alwaysBounceVertical = true
                self.addSubview(header)
                self.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(headerPanScroll(_:))))
            }
        }
    }
    
    /// 拖动手势操作
    ///
    /// - Parameter gesture: 拖动手势
    @objc func headerPanScroll(_ gesture: UIPanGestureRecognizer) {
        if self.czx_headerView?.state ?? .pulling == .releaseToRefresh {
            if self.czx_headerView?.isAutoRefresh ?? true {
                self.czx_headerView?.state = .refreshing
            } else {
                if gesture.state == UIGestureRecognizerState.ended || gesture.state == UIGestureRecognizerState.cancelled {
                    self.czx_headerView?.state = .refreshing
                }
            }
        }
    }
    
    
    /// 上拉加载视图
    public var czx_footerView: RefreshFooterView? {
        get {
            return self.viewWithTag(footerTag) as? RefreshFooterView
        }
        
        set {
            if let footer = newValue {
                footer.tag = footerTag
                self.alwaysBounceVertical = true
                self.addSubview(footer)
            }
        }
    }
    
    /// 根据观察到的值对界面进行相应的设置
    ///
    /// - Parameters:
    ///   - keyPath: 对象的属性
    ///   - object: 观察的对象
    ///   - change: 改变的值
    ///   - context: 相应的文本
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if keyPath! == "contentSize" {
            if let size = change?[NSKeyValueChangeKey.newKey] as? CGSize {
                self.czx_footerView?.frame.origin.y = size.height
            }
        }
        
        if keyPath! == "contentOffset" {
            if let point = change?[NSKeyValueChangeKey.newKey] as? CGPoint {
                if context! == &headerTag {
                    if point.y < 0 {
                        czx_headerView?.pullToRefresh(y: point.y)
                    }
                } else if context! == &footerTag {
                    if point.y > 0 {
                        czx_footerView?.pullToRefresh(y: point.y)
                    }
                }
            }
        }
    }
    
    /// 移除所有的观察者
    public func removeObservers() {
        self.czx_headerView?.removeObserver()
        self.czx_footerView?.removeObserver()
    }
}

extension UIScrollView: UIGestureRecognizerDelegate {
    
    /// 设置手势冲突
    ///
    /// - Parameters:
    ///   - gestureRecognizer: 自定义的手势
    ///   - otherGestureRecognizer: 系统自定义手势
    /// - Returns: 是否允许冲突
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if (gestureRecognizer.state != UIGestureRecognizerState.possible) {
            return true
        }
        return false
    }
}

