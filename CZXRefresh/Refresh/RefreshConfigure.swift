//
//  RefreshConfigure.swift
//  CZXRefresh
//
//  Created by 陈主昕 on 2018/1/27.
//  Copyright © 2018年 average. All rights reserved.
//

import UIKit

/// 下拉刷新视图的类型
///
/// - `default`: 默认类型(包含一张图片，文本提示和上次刷新时间)
/// - imageAndText: 有图片和文本的类型
/// - image: 只有图片
/// - text: 只有文本
/// - custom: 自定义类型
public enum RefreshHeaderViewType {
    case `default`
    case imageAndText
    case image
    case text
    case custom
}

/// 上拉加载视图的类型
///
/// - `default`: 默认类型(包含一张图片和文本提示)
/// - text: 只有文本
/// - image: 只有图片
/// - custom: 自定义类型
public enum RefreshFooterViewType {
    case `default`
    case text
    case image
    case custom
}

/// 刷新视图的状态
///
/// - pulling: 下拉状态
/// - releaseToRefresh: 松手开始刷新状态
/// - refreshing: 正在刷新状态
/// - refreshed: 刷新完成状态
public enum RefreshHeaderViewState {
    /// 下拉状态
    case pulling
    /// 松手开始刷新状态
    case releaseToRefresh
    /// 正在加载状态
    case refreshing
    /// 刷新完成状态
    case refreshed
}

/// 加载视图的状态
///
/// - normal: 正常状态(未加载时)
/// - refreshing: 正在加载状态
/// - endRefresh: 所有数据加载完状态
public enum RefreshFooterViewState {
    /// 正常状态
    case normal
    /// 正在加载状态
    case refreshing
    /// 所有数据加载完状态
    case endRefresh
}

/// 默认刷新视图宽度
public var windowWidth = UIScreen.main.bounds.width
/// 默认下拉刷新视图高度
public var defaultHeaderHeight: CGFloat = 50
/// 默认上拉加载视图高度
public var defaultFooterHeight: CGFloat = 50
/// 默认下拉刷新视图下拉高度
public var defaultHeaderPullHeight: CGFloat = 50
/// 默认上拉加载视图上拉高度
public var defaultFooterPullHeight: CGFloat = 50

/// 下拉刷新视图标签
var headerTag = 1996
/// 上拉加载视图标签
var footerTag = 1997

