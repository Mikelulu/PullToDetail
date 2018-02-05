//
//  SecondViewController.swift
//  PullDetail
//
//  Created by 陆 on 2018/2/5.
//  Copyright © 2018年 陆. All rights reserved.
//

import UIKit

class SecondViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.white
        self.navigationItem.title = "详情"
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        print("详情页释放")
    }
}
