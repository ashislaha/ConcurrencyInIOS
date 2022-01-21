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
	

	let dispatchGroup = DispatchGroup()
	
	// test value
	var evenValue: Int = 0
	
	func computeWorkItems() {
		
		let dispatchConcurrentQueue1 = DispatchQueue(label: "concurrentQueue1",
													 qos: .utility,
													 attributes: .concurrent)
		var workItem1: DispatchWorkItem?
		workItem1 = DispatchWorkItem {
			
			print("[DispatchGroupWithWorkItems] DispatchWorkItem 1")
			
			for i in 0...4 {
				
				if let wrkItem = workItem1, wrkItem.isCancelled {
					print("work item is cancelled")
					break
				}
				
				print("workitem 1: ", i)
				self.evenValue += 2
				sleep(1)
			}
		}
		
		workItem1?.notify(queue: DispatchQueue.global(qos: .background)) {
			print("[DispatchGroupWithWorkItems] work item-1 is done. evenValue = \(self.evenValue)")
		}
		
		if let workItem = workItem1 {
			dispatchConcurrentQueue1.async(group: dispatchGroup, execute: workItem)
		}
	
		
		let workitem2 = DispatchWorkItem {
			print("[DispatchGroupWithWorkItems] DispatchWorkItem 2")
		}
		dispatchConcurrentQueue1.async(group: dispatchGroup, execute: workitem2)
		
		
		// we can attach multiple queue into the same dispatch group.
		let dispatchConcurrentQueue2 = DispatchQueue.global(qos: .userInitiated)
		let workItem3 = DispatchWorkItem {
			print("[DispatchGroupWithWorkItems] DispatchWorkItem 3")
		}
		dispatchConcurrentQueue2.async(group: dispatchGroup, execute: workItem3)
		
		// NOT correct to notify the completion <-- as below block contains async code
		dispatchConcurrentQueue2.async {
			self.dispatchGroup.enter()
			print("[DispatchGroupWithWorkItems] Async work 4")
			
			DispatchQueue.global(qos: .background).async {
				
				defer {
					self.dispatchGroup.leave()
				}
				
				sleep(6)
				print("[DispatchGroupWithWorkItems] Async work 4 completed")
			}
		}
		
		// Behavior: queue1 <-- [workitem1, workitem2] and queue2 <-- [workItem3, a closure]
		
		dispatchGroup.notify(queue: DispatchQueue.global()) {
			print("Now all workitems are completed")
		}
		
		// what will happen if some job did not finish in definite time, we want to set a timeout and proceed further
		// we can wait for next 3 sec until all the jobs are completed on the current thread
		// It is important that all the jobs are still running even if timeout happens.
		
		// CAUTION: BLOCKING CALL!!!!
		let waitingState = dispatchGroup.wait(timeout: .now() + 3)
		if waitingState == .timedOut {
			print("Jobs did not finish in next 3 sec")
			workItem1?.cancel()
			
		} else if waitingState == .success {
			print("All jobs are completed before timeout")
		}
	}
	
	class func test() {
		let obj = DispatchGroupWithWorkItems()
		obj.computeWorkItems()
	}
}
