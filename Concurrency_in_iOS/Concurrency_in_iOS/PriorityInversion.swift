//
//  PriorityInversion.swift
//  Concurrency_in_iOS
//
//  Created by Ashis Laha on 03/12/21.
//  Copyright © 2021 Ashis Laha. All rights reserved.
//

import Foundation

class ProirityInversion {
	
	private let highPriorityQueue = DispatchQueue.global(qos: .userInteractive)
	private let mediumPriorityQueue = DispatchQueue.global(qos: .userInitiated)
	private let lowPriorityQueue = DispatchQueue.global(qos: .utility)
	
	private let semaphore = DispatchSemaphore(value: 1)
	
	// priority inversion <-- even if we are assigning tasks to higher priority Queue, they are executing after
	// lower priority Queue assinging task. This can be happen due to multiple reasons:
	// Example -- If the higher priority Queue shares a resource which is hold by lower priority Queue the OS changes
	// the priority of Queue, and the lower priority Queue executes its task before the higher priority Queue executes.
	
	func test() {
		
		highPriorityQueue.async {
			defer {
				self.semaphore.signal()
			}
			
			// wait 1 sec so that all other tasks should be enqueued.
			sleep(1)
			
			self.semaphore.wait()
			print("High priority task running")
		}
		
		for i in 1...10 {
			mediumPriorityQueue.async {
				print("Medium priority task \(i)")
				
				// medium level task may take different time (upper bound 3)
				let waitingTime = arc4random_uniform(3);
				sleep(waitingTime)
			}
		}
		
		lowPriorityQueue.async {
			defer {
				self.semaphore.signal()
			}
			
			self.semaphore.wait()
			print("Low priority task -- long running task")
			sleep(5)
		}
	}
	
	// solution
	// the solution here to use a different Queue, instead of using
	
	
}



