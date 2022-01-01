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
	}
	
	func executeConcurrently() {
		
		let time1 = DispatchTime.now()
		// concurrent
		let concurrentQueue = DispatchQueue(label: "concurrent", attributes: .concurrent)
		let dispatchGroup = DispatchGroup()
		
		concurrentQueue.async(group: dispatchGroup) {
			// assume -- this is executing by thread 1
			self.task1()
		}
		concurrentQueue.async(group: dispatchGroup) {
			// assume - this is executing by thread 2
			self.task2()
		}
		let time2 = DispatchTime.now()
		
		// ERROR as async work will execute concurrently and we do not know when both tasks are completed.
		print("ERROR: time taken while executing concurrently = ", time1.distance(to: time2))
		
		dispatchGroup.notify(queue: .global(qos: .default)) {
			let completed = DispatchTime.now()
			
			// ERROR as async work will execute concurrently and we do not know when both tasks are completed.
			print("[Concurrent Queue] time taken while executing concurrently = ", time1.distance(to: completed))
		}
	}
	
	class func test() {
		let timeProfile = ConcurrencyTimeProfile()
		timeProfile.executeSequential()
		timeProfile.executeConcurrently()
	}
}
