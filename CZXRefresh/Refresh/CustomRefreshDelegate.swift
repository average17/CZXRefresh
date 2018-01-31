//
//  RefreshView.swift
//  CZXRefresh
//
//  Created by 陈主昕 on 2018/1/27.
//  Copyright © 2018年 average. All rights reserved.
//

import UIKit

public protocol CustomHeaderRefreshDelegate {
    
    /// 自定义正常状态时的视图
    ///
    /// - Returns: 正常状态时的视图
    func setNormalView() -> UIView
    
    /// 自定义放手开始刷新时的视图
    ///
    /// - Returns: 放手开始刷新时的视图
    func setReleaseToRefreshView() -> UIView
    
    /// 自定义刷新时的视图
    ///
    /// - Returns: 刷新时的视图
    func setRefreshingView() -> UIView
    
    /// 自定义刷新完成时的视图
    ///
    /// - Returns: 刷新完成时的视图
    func setRefreshedView() -> UIView
    
    /// 自定义下拉时的动画
    ///
    /// - Parameters:
    ///   - view: 正常状态时的视图
    ///   - percent: 下拉的百分比
    func setPullingAnimation(view: UIView, percent: CGFloat)
    
    /// 自定义放手开始刷新时刷新的动画
    ///
    /// - Parameter view: 放手开始刷新的视图
    func setReleaseToRefreshAnimation(view: UIView)
    
    /// 自定义刷新时的动画
    ///
    /// - Parameter view: 刷新时的视图
    func setRefreshingAnimation(view: UIView)
}

public protocol CustomFooterRefreshDelegate {
    
    /// 自定义正常状态时的视图
    ///
    /// - Returns: 正常状态时的视图
    func setNormalView() -> UIView
    
    /// 自定义刷新状态时的视图
    ///
    /// - Returns: 刷新状态时的视图
    func setRefreshingView() -> UIView
    
    /// 自定义刷新完成时的视图
    ///
    /// - Returns: 刷新完成时的视图
    func setEndRefreshView() -> UIView
    
    /// 自定义上拉时的动画
    ///
    /// - Parameters:
    ///   - view: 正常状态时的视图
    ///   - percent: 上拉的百分比
    func setPullingAnimation(view: UIView, percent: CGFloat)
    
    /// 自定义刷新时的动画
    ///
    /// - Parameter view: 刷新时的视图
    func setRefreshingAnimation(view: UIView)
    
}

