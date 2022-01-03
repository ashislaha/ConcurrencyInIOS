//
//  TestOperationQueue.swift
//  Concurrency_in_iOS
//
//  Created by Ashis Laha on 09/12/21.
//  Copyright © 2021 Ashis Laha. All rights reserved.
//

import Foundation

// Operation queue is used to manage a scheduling operation.

// OperationQueue allows you to handle operations into 3 ways:
// 1. pass it directly to operation queue
// 2. pass a closure
// 3. pass an array of operations.
// 4. add barrier block to block the curren thread until barrier task is completed.
// (similar concept like concurrentQueue(with barrier:) )

class TestOperationQueue {
	
	// OperationQueue executes an operation when it is ready.
	// Ready of an operation is defined based on its dependency information.
	
	// important fact --> once an operation is added to an operation queue, it cannot be added to any other operation queue.
	
	func handleOperationsConcurrently() {
		let operationQueue = OperationQueue()
		operationQueue.maxConcurrentOperationCount = 2 // if we set 1, it will work like serial dispatch queue.
		
		// underlying dispatchQueue:
		// you can speficy an underlying dispatchQueue for an operation Queue. You must not specify main queue for this.
		// You must set this value when there is no operation in OperationQueue.
		// https://developer.apple.com/documentation/foundation/nsoperationqueue/1415344-underlyingqueue
		// default queue is global dispatchQueue with .default QoS
		
		//operationQueue.underlyingQueue = DispatchQueue.global(qos: .userInteractive)
		
		
		let operation1 = BlockOperation {
			print("[TestOperationQueue] starting operation 1")
			sleep(1)
			
		}
		operation1.completionBlock = {
			print("[TestOperationQueue] completed operation 1")
		}
		
		let operation2 = BlockOperation {
			print("[TestOperationQueue] starting operation 2")
			sleep(2)
		}
		operation2.completionBlock = {
			print("[TestOperationQueue] completed operation 2")
		}
		
		// In operationQueue, you can add an operation with different quality of service.
		// the quality of service of an operationQueue can be overriden by the operation's QOS.
		
		operation2.qualityOfService = .userInteractive
		operation1.qualityOfService = .background
	
		// waiting for completion --> waitUntilAllOperationsAreFinished()
		// It is a blocking call and the current thread will be blocked until all the operations are completed.
		// YOU must not call this method on Main Queue. If you want to use this method, use a private serial queue.
		
		//operationQueue.waitUntilAllOperationsAreFinished()
		
		// what if I am looking for few operations to complete not all of them?
		// we can use addOperations(op, waitUntilFinish: true)
		// CAUTION BLOCKING operation on current thread!!! when waitUntilFinished = true
		operationQueue.addOperations([operation1, operation2], waitUntilFinished: false)
		
		print("[TestOperationQueue] after adding operations")
		
		// to cancel all operations
		//operationQueue.cancelAllOperations()
	}
	
	class func test() {
		let obj = TestOperationQueue()
		obj.handleOperationsConcurrently()
	}
}


