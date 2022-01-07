//
//  RaceCondition.swift
//  Concurrency_in_iOS
//
//  Created by Ashis Laha on 02/12/21.
//  Copyright © 2021 Ashis Laha. All rights reserved.
//

import Foundation

// Race condition -- when mutliple threads tries to update a shared resource, a race condition will occur and
// the end result is un-defined.

// we can solve the race condition with multiple technique ( like using a serial queue, semaphore, lock)
// But the ultimate goal to solve the race condition is the shared resource must be accessed by a single thread,
// concurrent access should be blocked.
// we can solve this using multiple technique --> (1) lock (2) semaphore (3) serial queue (4) concurrent queue

class RaceCondition {
	
	var balance: Int = 1000
		
	func update() {
		
		let concurrentQueue = DispatchQueue(label: "ConcurrentQ1",
											qos: .userInitiated,
											attributes: .concurrent)
		
		// task - 1 (thread 1)
		concurrentQueue.async {
			self.debit(amount: 600, processingType: "ATM")
		}
		
		// task -- 2 (thread 2)
		concurrentQueue.async { [weak self] in
			self?.debit(amount: 700, processingType: "Netbanking")
		}
	}
	
	class func test() {
		let obj = RaceCondition()
		obj.update()
	}
	
	private func credit(amount: Int) {
		balance = balance + amount
		print(balance)
	}
	
	private func debit(amount: Int, processingType: String = "UPI") {
		
		guard balance > amount else {
			print("[RaceCondition] cannot withdraw insufficient balance - mode ", processingType)
			return
		}
		
		print("[RaceCondition] sufficient balance:", processingType)
		
		// Do some internal processing
		Thread.sleep(forTimeInterval: 1)
			
		balance = balance - amount
		
		print("[RaceCondition] debited successfully \(amount) : mode -", processingType)
		print("[RaceCondition] balance = ", balance)
	}
}



// Solution with Serial Queue
// Drawback: Read should be concurrent instead of serial.
class RaceConditionSolution {
	
	private let threadSafeQueue = DispatchQueue(label: "Serial Queue")
	
	private var _balance: Double = 0
	var balance: Double {
		get {
			threadSafeQueue.sync {
				return _balance
			}
		}
		
		set {
			threadSafeQueue.sync {
				_balance = newValue
			}
		}
	}
	
}

// solution with concurrent queue
class RaceConditionAnotherSolutionWithThreadBarrier {
	
	// we can use a concurrent queue with barrier. With barrier, it will act like a Serial Queue.
	private let threadSafeConcurrentQueue = DispatchQueue(label: "Concurrent Queue",
														  attributes: .concurrent)
	
	private var _balance: Double = 0
	var balance: Double {
		
		get {
			return _balance
		}
		
		set {
			// the berrier flag ensures that concurrent queue does not execute any other tasks
			// while executing the barrier process.
			// Once the barrier task completes, all tasks submitted to concurrent queue will execute in parallel.
			threadSafeConcurrentQueue.async(flags: .barrier) { [weak self] in
				self?._balance = newValue
			}
		}
		
	}
	
}

