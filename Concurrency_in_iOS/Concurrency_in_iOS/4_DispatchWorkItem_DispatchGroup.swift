//
//  TestDispatchGroup.swift
//  Concurrency_in_iOS
//
//  Created by Ashis Laha on 01/12/21.
//  Copyright © 2021 Ashis Laha. All rights reserved.
//

import Foundation

// If a workitem contains async calls then we can use enter() and leave() method of DispatchQueue.
// If it has sync opertions, we can directly assign it to DispatchGroup.
class DispatchGroupWithWorkItems {
	
	let dispatchConcurrentQueue1 = DispatchQueue(label: "concurrentQueue1",
												 qos: .utility,
												 attributes: .concurrent)
	
	let dispatchConcurrentQueue2 = DispatchQueue.global(qos: .userInitiated)
	let dispatchGroup = DispatchGroup()
	
	// queue1 <-- [workitem1, workitem2] and queue2 <-- [workItem3, a closure]
	func computeWorkItems() {
		
		let workItem1 = DispatchWorkItem {
			print("[DispatchGroupWithWorkItems] DispatchWorkItem 1")
		}
		dispatchConcurrentQueue1.async(group: dispatchGroup, execute: workItem1)
		
		let workitem2 = DispatchWorkItem {
			sleep(1)
			print("[DispatchGroupWithWorkItems] DispatchWorkItem 2")
		}
		dispatchConcurrentQueue1.async(group: dispatchGroup, execute: workitem2)
		
		// we can attach multiple queue into the same dispatch group.
		let workItem3 = DispatchWorkItem {
			print("[DispatchGroupWithWorkItems] DispatchWorkItem 3")
		}
		dispatchConcurrentQueue2.async(group: dispatchGroup, execute: workItem3)
		
		dispatchConcurrentQueue2.async {
			
			self.dispatchGroup.enter()
			DispatchQueue.global(qos: .background).async {
				defer { self.dispatchGroup.leave() }
				
				sleep(1)
				print("[DispatchGroupWithWorkItems] Async work 4")
			}
		}
		
		dispatchGroup.notify(queue: .main) {
			print("Now all workitems are completed")
		}
		
		// what will happen if some job did not finish in definite time, we want to set a timeout and proceed further
		// we can wait for next 3 sec until all the jobs are completed on the current thread
		// It is important that all the jobs are still running even if timeout happens.
		
		// CAUTION: BLOCKING CALL!!!!
		let waitingState = dispatchGroup.wait(timeout: .now() + 3)
		if waitingState == .timedOut {
			print("Jobs did not finish in next 3 sec")
			
		} else if waitingState == .success {
			print("All jobs are completed before timeout")
		}
	}
	
	class func test() {
		let obj = DispatchGroupWithWorkItems()
		obj.computeWorkItems()
	}
}