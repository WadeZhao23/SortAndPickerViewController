//
//  ViewController.swift
//  SortAndPickerProject
//
//  Created by Wade Zhao on 3/9/19.
//  Copyright © 2019 Wade Zhao. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
	
	override func viewDidLoad() {
		super.viewDidLoad()
	}
	
	@IBAction func tapEnterButton(_ sender: Any) {
		var dataSource: [String] = []
		for i in 0..<10 {
			dataSource.append("中国\(i)")
			dataSource.append("美国\(i)")
			dataSource.append("英国\(i)")
			dataSource.append("Russian\(i)")
		}
		let vc = SortAndPickerViewController.show("SortVC", dataSource: dataSource, selectedData: []) { (result) in
			print(result)
		}
		navigationController?.pushViewController(vc, animated: true)
	}
	
}

