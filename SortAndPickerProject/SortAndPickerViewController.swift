//
//  SortAndPickerViewController.swift
//  SortAndPickerProject
//
//  Created by Wade Zhao on 3/9/19.
//  Copyright © 2019 Wade Zhao. All rights reserved.
//

import UIKit

class SortAndPickerViewController: UIViewController {
	var dataSource: [String] = []
	var selectedData: [String] = []
	var completionClosure: (([String]) -> Void)?
	
	private var sortedData: [[String]] = []
	private var indexArray: [String] = []
	
	lazy var tableView: UITableView = {
		let result = UITableView(frame: view.frame, style: .grouped)
		return result
	}()
	
	private var collation: UILocalizedIndexedCollation = UILocalizedIndexedCollation.current()
	
	// MARK: - Life Cycle
	
	class func show(_ title: String, dataSource: [String], selectedData: [String]?, completctionClosure: @escaping (([String]) -> Void)) -> SortAndPickerViewController {
		let vc = SortAndPickerViewController()
		vc.title = title
		vc.dataSource = dataSource
		vc.selectedData = selectedData ?? []
		vc.completionClosure = completctionClosure
		return vc
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		setUpDoneBarButtonItem()
		setUpTableView()
		configLocalizedSections()
	}
	
	// MARK: - SetUp UI
	
	private func setUpDoneBarButtonItem() {
		navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(tapRightBarButtonItem))
	}
	
	@objc private func tapRightBarButtonItem() {
		completionClosure?(selectedData)
	}
	
	private func setUpTableView() {
		view.addSubview(tableView)
		view.backgroundColor = UIColor.gray
		
		tableView.translatesAutoresizingMaskIntoConstraints = false
		tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
		tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
		tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
		tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
		
		tableView.delegate = self
		tableView.dataSource = self
		tableView.backgroundColor = UIColor.gray
		tableView.separatorColor = UIColor.lightGray
		tableView.sectionIndexColor = UIColor.black
		tableView.sectionIndexBackgroundColor = UIColor.clear
		tableView.cellLayoutMarginsFollowReadableWidth = false
		tableView.tableFooterView = UIView()
		tableView.register(SPUITableViewSectionHeader.self, forHeaderFooterViewReuseIdentifier: NSStringFromClass(SPUITableViewSectionHeader.self))
		tableView.register(UITableViewCell.self, forCellReuseIdentifier: NSStringFromClass(UITableViewCell.self))
	}
}

// MARK: - Index Collation

extension SortAndPickerViewController {
	fileprivate func configLocalizedSections() {
		let sectionCount = collation.sectionTitles.count
		
		for _ in 0..<sectionCount {
			let array: [String] = []
			sortedData.append(array)
		}
		
		for index in dataSource {
			let number = collation.section(for: index, collationStringSelector: #selector(getter: debugDescription))
			var classifyArray = sortedData[number]
			classifyArray.append(index)
			sortedData[number] = classifyArray
		}
		
		for i in 0..<sectionCount {
			let temp = sortedData[i]
			let sortedSectionArray = collation.sortedArray(from: temp, collationStringSelector: #selector(getter: debugDescription)) as? [String]
			if let result = sortedSectionArray {
				sortedData[i] = result
				if !result.isEmpty {
					indexArray.append(collation.sectionTitles[i])
				}
			}
		}
		
		sortedData.removeAll(where: { $0.isEmpty })
		tableView.reloadData()
	}
}

// MARK: - UITableView Delegate & DataSource

extension SortAndPickerViewController: UITableViewDelegate, UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return sortedData[section].count
	}
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return indexArray.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		return configUITableViewCell(indexPath)
	}
	
	func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		let headerView = self.tableView.dequeueReusableHeaderFooterView(withIdentifier: NSStringFromClass(SPUITableViewSectionHeader.self)) as! SPUITableViewSectionHeader
		headerView.sectionTextLabel.text = indexArray[section]
		return headerView
	}
	
	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return UITableView.automaticDimension
	}
	
	func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
		return 44.0
	}
	
	func sectionIndexTitles(for tableView: UITableView) -> [String]? {
		return indexArray
	}
	
	func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
		tableView.scrollToRow(at: IndexPath(row: 0, section: index), at: .top, animated: true)
		return index
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		let data = sortedData[indexPath.section][indexPath.row]
		if selectedData.contains(data) {
			selectedData.remove(object: data)
		} else {
			selectedData.append(data)
		}
		
		tableView.reloadData()
	}
	
	func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
		return 50.0
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return UITableView.automaticDimension
	}
	
	func configUITableViewCell(_ indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(UITableViewCell.self))
		cell?.textLabel?.text = sortedData[indexPath.section][indexPath.row]
		if selectedData.contains(sortedData[indexPath.section][indexPath.row]) {
			cell?.textLabel?.textColor = UIColor.blue
			cell?.accessoryView = UIImageView(image: UIImage(named: "对勾"))
		} else {
			cell?.textLabel?.textColor = UIColor.black
			cell?.accessoryView = nil
		}
		return cell ?? UITableViewCell()
	}
}

open class SPUITableViewSectionHeader: UITableViewHeaderFooterView {
	open var backgroundImageView: UIImageView {
		return self._backgroundImageView
	}
	
	open var sectionTextLabel: UILabel!
	fileprivate var _backgroundImageView: UIImageView!
	
	public override init(reuseIdentifier: String?) {
		super.init(reuseIdentifier: reuseIdentifier)
		_init()
	}
	
	public required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		_init()
	}
	
	fileprivate func _init() {
		_backgroundImageView = UIImageView()
		_backgroundImageView.backgroundColor = UIColor.white
		backgroundView = _backgroundImageView
		
		sectionTextLabel = UILabel()
		sectionTextLabel.numberOfLines = 1
		sectionTextLabel.backgroundColor = UIColor.clear
		sectionTextLabel.textAlignment = NSTextAlignment.left
		sectionTextLabel.textColor = UIColor.black
		contentView.addSubview(sectionTextLabel)
	}
	
	open override func layoutSubviews() {
		super.layoutSubviews()
		
		sectionTextLabel.frame = CGRect(x: 16, y: 0, width: bounds.size.width - 32, height: bounds.size.height)
	}
	
	open override func prepareForReuse() {
		super.prepareForReuse()
		
		sectionTextLabel.text = ""
	}
}

extension Array where Element: Equatable {
	// Remove collection element that is equal to the given `object`:
	mutating func remove(object: Element?) {
		if let object = object {
			removeAll { (element) -> Bool in
				element == object
			}
		}
	}
	
	mutating func move(from oldIndex: Index, to newIndex: Index) {
		if oldIndex == newIndex { return }
		if abs(newIndex - oldIndex) == 1 { return swapAt(oldIndex, newIndex) }
		insert(remove(at: oldIndex), at: newIndex)
	}
}
