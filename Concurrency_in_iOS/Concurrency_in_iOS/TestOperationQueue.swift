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

class TestOperationQueue {
	
	// OperationQueue executes an operation when it is ready.
	// Ready of an operation is defined based on its dependency information.
	
	// important fact --> once an operation is added to an operation queue, it cannot be added to any other operation queue.
	
	// waiting for completion --> waitUntilAllOperationsAreFinished()
	// It is a blocking call and the current thread will be blocked until all the operations are completed.
	// YOU must not call this method on Main Queue. If you want to use this method, use a private serial queue.
	
	// what if I am looking for few operations to complete not all of them?
	// we can use addOperations(op, waitUntilFinish: true)
	
	// In operationQueue, you can add an operation with different quality of service.
	// the default quality of service of an operation is .background
	// the quality of service of an operationQueue can be overriden by the operation's QOS.
	
	// Pause the dispatchQueue by setting isSuspended = true. In-flight operations will continue to complete but
	// newly added operations will not scheduled until we made isSuspended = false
	
	// we can define how many max number of operations can execute concurrently. maxConcurrentOperationCount
	// you cannot set a very large number here as your device is capable of handling some max number of thread allocation.
	// when maxConcurrentOperationCount <-- 1 then the OperationQueue will behave like Serial Queue.
	
	// underlying dispatchQueue:
	// you can speficy an underlying dispatchQueue for an operation Queue. You must not specify main queue for this.
	
	
		
	
	
}


