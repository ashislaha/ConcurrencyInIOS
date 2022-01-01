//
//  TestQueue.swift
//  Concurrency_in_iOS
//
//  Created by Ashis Laha on 02/07/21.
//  Copyright © 2021 Ashis Laha. All rights reserved.
//

// tutorials -- https://metova.com/concurrency-in-ios/

import Foundation

// [Custom Queue           GCD Queue              thread]

// serial queue           Main Queue             Main

// serial queue           Serial queue          [GCD thread pool]

// concurrent queue        Concurrent Queue     [GCD thread pool]

// Instead of creating mulitple concurrent queue, we can use global() queue which gives us the concurrency.

class TestQueue {
	
	let serialQueue = DispatchQueue(label: "serialQueue")
	let concurrentQueue = DispatchQueue(label: "concurrentQueue", attributes: .concurrent)
	
	// dispatch queue with QOS
	let concurrentQueueBackground = DispatchQueue(label: "concurrent background",
												  qos: .background,
												  attributes: .concurrent)
	
	// not use any-where
	let globalQueue = DispatchQueue.global(qos: .background)
	
	func testSerialQueue() {
		
		serialQueue.async {
			print("serial queue -- task 1")
			
			// having some task
			sleep(1)
			
			print("serial queue -- task 1 finished")
			
		}
		
		serialQueue.async {
			print("serial queue -- task 2")
			
			// having some task
			sleep(1)
			
			print("serial queue -- task 2 finished")
		}
		
		serialQueue.async {
			print("serial queue -- task 3")
			
			// having some task
			sleep(1)
			
			print("serial queue -- task 3 finished")
		}
	}
	
	func testConcurrentQueue() {
		concurrentQueue.async {
			print("concurrent queue -- task 1")
			
			// having some task
			self.updateMessage(message: "task 1")
			print("concurrent queue -- task 1 finished")
		}
		concurrentQueue.async {
			print("concurrent queue -- task 2")
			// having some task
			self.updateMessage(message: "task 2")
			print("concurrent queue -- task 2 finished")
		}
		concurrentQueue.async {
			print("concurrent queue -- task 3")
			// having some task
			self.updateMessage(message: "task 3")
			print("concurrent queue -- task 3 finished")
		}
	}
	
	// Use barrier to do a sychronize write in concurrent queue
	
	var messages: [String] = []
	let semaphore = DispatchSemaphore(value: 1)
	
	private func updateMessage(message: String) {
		
		// multiple thread are updating the reosuce "message" in parallel. so we need sync here
		semaphore.wait() // decrement the counter by 1 and check whether value < 0
		messages.append(message)
		print(messages)
		semaphore.signal() // increment the counter by 1
	}
}

