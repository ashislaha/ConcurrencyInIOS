//
//  DispatchQueueSyncAsyncOperation.swift
//  Concurrency_in_iOS
//
//  Created by Ashis Laha on 31/12/21.
//  Copyright © 2021 Ashis Laha. All rights reserved.
//

import Foundation
import os

class DispatchQueueSyncAsyncOperation {
	
	func task1() {
		sleep(1)
	}
	
	func task2() {
		sleep(2)
	}
	func serialQueueOperations() {
		let time1 = DispatchTime.now()
		
		let serialQueue = DispatchQueue(label: "serial") // no main serial queue
		let dispathGroup = DispatchGroup()
		
		serialQueue.async(group: dispathGroup) {
			self.task1()
		}
		
		serialQueue.async(group: dispathGroup) {
			self.task2()
		}
		
		dispathGroup.notify(queue: .main) {
			let time2 = DispatchTime.now()
			print("[ASYNC serial] Time taken by the serial queue in async operations = ", time1.distance(to: time2))
		}
	}
	
	// recommended way: another way to measure how much time a code block is taking.
	let pointOfInterest = OSLog(subsystem: "DispatchQueue", category: .pointsOfInterest)
	
	func concurrentQueueSyncOperations() {
		let time1 = DispatchTime.now()
		
		os_signpost(.begin, log: pointOfInterest, name: "concurrentQueueSyncOperations")
		defer {
			os_signpost(.end, log: pointOfInterest, name: "concurrentQueueSyncOperations")
		}
		
		let concurrentQueue = DispatchQueue(label: "concurrent", attributes: .concurrent)
		
		// Caution: BLOCKING!!!
		concurrentQueue.sync {
			self.task1()
		}
		
		// Caution: BLOCKING!!!
		concurrentQueue.sync {
			self.task2()
		}
		
		let time2 = DispatchTime.now()
		print("[SYNC concurrent] Time taken by the concurrent queue in sync operations = ", time1.distance(to: time2))
	}
	
	class func test() {
		let obj = DispatchQueueSyncAsyncOperation()
		obj.serialQueueOperations()
		obj.concurrentQueueSyncOperations()
	}
}
