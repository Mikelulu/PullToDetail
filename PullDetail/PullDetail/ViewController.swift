//
//  ViewController.swift
//  PullDetail
//
//  Created by 陆 on 2018/2/2.
//  Copyright © 2018年 陆. All rights reserved.
//

import UIKit
import Foundation
import WebKit

let screenW = UIScreen.main.bounds.size.width
let screenH = UIScreen.main.bounds.size.height
let naviH = UIApplication.shared.statusBarFrame.size.height + 44

let maxContentOffSet_Y: CGFloat = 60

class ViewController: UIViewController {
    
    /// 底部ScrollerView
    fileprivate lazy var mainScrollerView: UIScrollView = {
        let scroller = UIScrollView.init(frame: CGRect.init(x: 0, y: naviH, width: screenW, height: screenH - naviH))
        scroller.isScrollEnabled = false // 禁止滑动
        scroller.isPagingEnabled = true
        scroller.contentSize = CGSize.init(width: screenW, height: screenH * 2)
        scroller.backgroundColor = UIColor.gray
        scroller.bounces = true
        return scroller
    }()
    /// 上部分的tableView
    fileprivate lazy var tableView: UITableView = {
        let table = UITableView.init(frame: CGRect.init(x: 0, y: 0, width: screenW, height: screenH - naviH), style: .plain)
        table.delegate = self
        table.dataSource = self
        
        let footLable = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: screenW, height: 60))
        footLable.text = "向上滑动，查看更多详情"
        footLable.font = UIFont.systemFont(ofSize: 14)
        footLable.textAlignment = .center
        table.tableFooterView = footLable
        return table
    }()
    
    /// 下部分的webView
    fileprivate lazy var webView: WKWebView = {
        let web = WKWebView.init(frame: CGRect.init(x: 0, y:screenH + naviH, width: screenW, height: screenH - naviH))
        web.load(URLRequest.init(url: URL.init(string: "https://github.com")!))
        
        return web
    }()
    
    // 上拉返回上一页 lable
    fileprivate lazy var headLab: UILabel = {
        let lable = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: screenW, height: 60))
        lable.textAlignment = .center
        lable.font = UIFont.systemFont(ofSize: 14)
        lable.text = "上拉，返回详情"
        lable.alpha = 0
        return lable
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        self.automaticallyAdjustsScrollViewInsets = false
        self.title = "马上赚"
        
        webView.uiDelegate = self
        webView.navigationDelegate = self
        webView.scrollView.delegate = self

        setupView()

        // 监听webView的滑动 改变文字动画
        webView.scrollView.addObserver(self, forKeyPath: "contentOffset", options: [.new, .old], context: nil)
        
        
        let lable = FPSLabel.init(frame: CGRect.init(x: 50, y: naviH, width: 0, height: 0))
        UIApplication.shared.delegate?.window??.addSubview(lable)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if let obj = object {
            if (((obj as! NSObject)) == webView.scrollView && keyPath == "contentOffset") {
                
                if let change = change {
                    print(change[NSKeyValueChangeKey.newKey] ?? 0)
                    let point: CGPoint = (webView.scrollView.value(forKeyPath: keyPath!) as! NSValue).cgPointValue
                    let offetY = point.y
                    headLabAnimation(offetY)
                }
            }
        }else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    deinit {
        webView.scrollView.removeObserver(self, forKeyPath: "contentOffset")
        print("shifang")
    }
}
extension ViewController {
    
    // 添加子视图
    private func setupView() {
        view.addSubview(mainScrollerView)
        mainScrollerView.addSubview(tableView)
        mainScrollerView.addSubview(webView)
        webView.addSubview(headLab)
    }
    // 进入详情页的动画
    fileprivate func goToDetailAnimation() {
        UIView.animate(withDuration: 0.3, animations: {
            // 改变frame
            self.webView.frame = CGRect.init(x: 0, y: 0, width: screenW, height: screenH - naviH)
            self.tableView.frame = CGRect.init(x: 0, y: -(screenH - naviH), width: screenW, height: screenH - naviH)
        }) { (finished) in
            
        }
    }
    // 返回上一个页面
    fileprivate func backToFirstPageAnimation() {
        UIView.animate(withDuration: 0.3) {
            // 改变frame
            self.tableView.frame = CGRect.init(x: 0, y: 0, width: screenW, height: screenH - naviH)
            self.webView.frame = CGRect.init(x: 0, y:screenH + naviH, width: screenW, height: screenH - naviH)
        }
    }
    // 头部文字动画
    fileprivate func headLabAnimation(_ offsetY: CGFloat) {
        headLab.alpha = -offsetY / 60.0
        headLab.center = CGPoint.init(x: screenW / 2.0, y: -offsetY/2.0)
        // 图标翻转，表示已超过临界值，松手就会返回上页
        if -offsetY > maxContentOffSet_Y {
            headLab.textColor = UIColor.red
            headLab.text = "释放，返回详情"
        } else {
            headLab.textColor = UIColor.black
            headLab.text = "上拉，返回详情"
        }
    }
}
extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 50
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "id")
        if cell == nil {
            cell = UITableViewCell.init(style: .default, reuseIdentifier: "id")
        }
        cell?.textLabel?.text = "第\(indexPath.row)行"
        return cell!
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let vc = SecondViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    /// 停止拖动
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        let offsetY = scrollView.contentOffset.y
        
        if scrollView is UITableView {
            // 能触发翻页的理想值:tableView整体的高度减去屏幕本省的高度
            let valueNum = tableView.contentSize.height - screenH - naviH
            if (offsetY - valueNum) > maxContentOffSet_Y {
                // 进入图文详情的动画
                goToDetailAnimation()
            }
        } else {
            if (offsetY < 0 && -offsetY > maxContentOffSet_Y) {
                // 返回上个页面
                backToFirstPageAnimation()
            }
        }
    }
}

extension ViewController: WKUIDelegate, WKNavigationDelegate {
    
    
}
