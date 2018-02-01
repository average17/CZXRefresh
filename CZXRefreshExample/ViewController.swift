//
//  ViewController.swift
//  CZXRefreshExample
//
//  Created by 陈主昕 on 2018/1/31.
//  Copyright © 2018年 average. All rights reserved.
//

import UIKit
import CZXRefresh

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var table: UITableView!
    var cellCount = 20
    var cellName = "数据"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        table = UITableView(frame: self.view.frame)
        table.delegate = self
        table.dataSource = self
        self.view.addSubview(table)
        
        let header = RefreshHeaderView(type: .default, action: printHelloHeader)
        table.czx_headerView = header
        
        let footer = RefreshFooterView(type: .default, action: printHelloFooter)
        footer.setText(text: "都加载完啦", type: .endRefresh)
        table.czx_footerView = footer
    }
    
    @objc func printHelloHeader() {
        DispatchQueue.global().async {
            print("-------------------------正在刷新 header")
            sleep(2)
            DispatchQueue.main.async {
                [weak self] in
                print("-------------------------刷新完成 header")
                self?.cellCount = 20
                self?.cellName = "刷新"
                self?.table.reloadData()
                self?.table.czx_headerView?.stopRefresh()
            }
        }
    }
    
    @objc func printHelloFooter() {
        DispatchQueue.global().async {
            print("-------------------------正在加载 footer")
            sleep(2)
            DispatchQueue.main.async {
                [weak self] in
                print("-------------------------加载完成 footer")
                self?.cellCount += 20
                self?.table.reloadData()
                if self!.cellCount < 40 {
                    self?.table.czx_footerView?.stopRefresh()
                } else {
                    print("-------------------------加载完所有数据 footer")
                    self?.table.czx_footerView?.endRefresh()
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "Cell")
        }
        
        cell?.textLabel?.text = "\(cellName)\(indexPath.row+1)"
        
        return cell!
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

