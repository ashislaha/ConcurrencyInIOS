//
//  ConcurrencyTimePrfile.swift
//  Concurrency_in_iOS
//
//  Created by Ashis Laha on 31/12/21.
//  Copyright © 2021 Ashis Laha. All rights reserved.
//

import Foundation

class ConcurrencyTimeProfile {
	
	func task1() {
		// takes one second of time
		sleep(1)
	}
	
	func task2() {
		// takes 2 seconds of time
		sleep(2)
	}
	
	func executeSequential() {
		let time1 = DispatchTime.now()
		// sequential (executed by main queue)
		task1()
		task2()
		let time2 = DispatchTime.now()
		print("[Main Serial] time taken while executing sequentially = ", time1.distance(to: time2))
		
		// we can check it in a different serial queue
		
	}
	
	func executeConcurrently() {
		
		// concurrent
		let concurrentQueue = DispatchQueue(label: "concurrent", attributes: .concurrent)
		
		concurrentQueue.async {
			// assume -- this is executing by thread 1
			self.task1()
		}
		concurrentQueue.async {
			// assume - this is executing by thread 2
			self.task2()
		}
				
	}
	
	class func test() {
		let timeProfile = ConcurrencyTimeProfile()
		timeProfile.executeSequential()
		timeProfile.executeConcurrently()
	}
}
