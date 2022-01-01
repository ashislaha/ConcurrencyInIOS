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

class RaceCondition {
	
	private var balance: Int = 0
	private let concurrentQueue = DispatchQueue(label: "ConcurrentQ1",
												qos: .userInitiated,
												attributes: .concurrent)
	private let concurrentQueue2 = DispatchQueue.global(qos: .userInitiated)
	
	private func credit(amount: Int) {
		balance += amount
		print(balance)
	}
	
	private func debit(amount: Int) {
		balance -= amount
		print(balance)
	}
	
	func update() {
		// task - 1 (concurrent Q1)
		concurrentQueue.async { [weak self] in
			self?.credit(amount: 10)
		}
		
		// task -- 2 (concurrent Q1)
		concurrentQueue.async { [weak self] in
			self?.debit(amount: 10)
		}
		
		// task - 3 (concurrent Q2)
		concurrentQueue2.async { [weak self] in
			self?.credit(amount: 15)
		}
		
		// task - 4 (concurrent Q2)
		concurrentQueue2.async { [weak self] in
			self?.debit(amount: 5)
		}
	}
	
	class func test() {
		let obj = RaceCondition()
		obj.update()
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
	
	// sometimes shared resources have more complex logic in getters and setters than setting a variable modification.
	// If we want to perform multiple read operation but single write operation,
	// we can use a concurrent queue with barrier. With barrier, it will act like a Serial Queue.
	
	private let threadSafeConcurrentQueue = DispatchQueue(label: "Concurrent Queue", attributes: .concurrent)
	
	private var _balance: Double = 0
	var balance: Double {
		
		get {
			// sync method to read the correct value but all other readers are operating in parallel.
			threadSafeConcurrentQueue.sync {
				return _balance
			}
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

