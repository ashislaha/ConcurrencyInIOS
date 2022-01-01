//
//  3_DispatchQueue_QOS.swift
//  Concurrency_in_iOS
//
//  Created by Ashis Laha on 31/12/21.
//  Copyright © 2021 Ashis Laha. All rights reserved.
//

import Foundation

class DispatchQueueQOS {
	let queue1 = DispatchQueue.global(qos: .userInteractive)
	let queue2 = DispatchQueue.global(qos: .utility)
	
	func queuePriorityUpdate() {
		
		queue2.async {
			print("[DispatchQueueQOS] Doing some small IO operation")
		}
		
		queue1.async {
			print("[DispatchQueueQOS] doing some calculation for user interaction on UI")
		}
		
	}
	
	class func test() {
		
		let obj = DispatchQueueQOS()
		obj.queuePriorityUpdate()
	}
}
