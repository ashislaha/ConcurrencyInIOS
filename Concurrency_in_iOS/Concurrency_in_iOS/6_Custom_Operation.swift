//
//  TestOperation.swift
//  Concurrency_in_iOS
//
//  Created by Ashis Laha on 02/07/21.
//  Copyright © 2021 Ashis Laha. All rights reserved.
//

import Foundation


// tutorials -- https://metova.com/concurrency-in-ios/

// SYNC
class SyncOperation: Operation {
	
	// each operation has 3 state
	// isReady
	// isExecuting
	// isFinished
	// isCancelled
	
	override func main() {
		// when an operation is exectuing, it actually execuing the main function
		
		print("\n[Sync operation] main is executing")
		SyncOperation.printStates(operation: self)
		
		sleep(1) // doing some heavy task taking 1 sec of time
	}
	
	override func cancel() {
		super.cancel()
		
		
		print("\n[Sync operation] cancelling current opration: ", name ?? "")
		SyncOperation.printStates(operation: self)
	}
	
	class func test() {
		let obj = SyncOperation()
		obj.name = "Sync Operation"
		
		// completion block should be defined before start() if main() contains sync operations.
		obj.completionBlock = {
			print("\n[Sync Operation] is completed.")
			printStates(operation: obj)
		}
		
		obj.cancel()
		obj.start()
	}
	
	private class func printStates(operation: Operation) {
		print("[Sync operation] isReady -->", operation.isReady)
		print("[Sync operation] isExecuting -->", operation.isExecuting)
		print("[Sync operation] isCancelled -->", operation.isCancelled)
		print("[Sync operation] isFinished -->", operation.isFinished)
	}
}

// ASYNC
class AsyncOperation: Operation {
	
	// Async Operation: what will happen when the operation main() func contains a async call?
	// how to maintain the state change of the operation (isReady, isExecuting, isFinished, isCancelled)
	// as the state-changes are read-only properties, we need to find a way to make it read-write
	// so that we can update it.
	// we can use KVO to listen those state change properties and construct the similar enum.
	
	private var task: URLSessionDataTask?
	
	var state: State = .ready {
		
		// you need to update 4 KVO when a state change happens.
		// state is changing from "isReady" --> "isExecuting" then isReady <-- false and isExecuting <-- true
		// How will the transition happen?
		// 1. willChange for isReady (false)
		// 2. willChange for isExecuting (true)
		// 3. didChange for isReady (false)
		// 4. didChange for isExecuting (true)
		
		willSet {
			// property observer
			willChangeValue(forKey: newValue.keyPath) // to state
			willChangeValue(forKey: state.keyPath) // from state
		}
		
		didSet {
			didChangeValue(forKey: oldValue.keyPath) // from state
			didChangeValue(forKey: state.keyPath) // to state
		}
	}
	
	override var isReady: Bool {
		// we need super.isReady as scheduler decides when an operation should move to isReady state,
		// We need that entry point and rest of the states will be maintained automatically
		// through property observer (KVOs)
		return super.isReady && state == .ready
	}
	
	override var isExecuting: Bool {
		return state == .executing
	}
	
	override var isFinished: Bool {
		return state == .finished
	}
	
	// Important for async operation
	override var isAsynchronous: Bool {
		return true
	}
	
	// If we do not use OperationQueue (where operation is automatically invoked for start() method and
	// it internally calls main() func of Operation) for handling operation and
	// we handle manually by calling start() method. so we need explicit hanlding logic.
	
	override func start() {
		
		print("\n[Async operation] start is executing")
		AsyncOperation.printStates(operation: self)
		
		// if the operation is already cancelled then nothing to do
		if isCancelled {
			state = .finished
			return
		}
		
		main()
		
		// main() will return immediately, as we want to maintain the isExecuting state to continue,
		// we must need to keep this. It internally calls KVO in property observer.
		state = .executing
	}
	
	override func main() {
		
		print("\n[Async operation] main is executing")
		
		guard !isCancelled
		else {
			AsyncOperation.printStates(operation: self)
			state = .finished
			return
		}
		
		let url = URL(string: "https://www.microsoft.com")!
		task = URLSession.shared.dataTask(with: url) { data, response, error in
			
			defer {
				AsyncOperation.printStates(operation: self)
				self.state = .finished
			}
			
			if error != nil {
				// have some error while hitting the end-point
			} else {
				// success (we should go to more granual level like data should be not-nil and JSON serialization etc.)
			}
		}
		task?.resume()
	}
	
	override func cancel() {
		super.cancel()
		
		print("\n[Async operation] cancel operation")
		AsyncOperation.printStates(operation: self)
		
		task?.cancel()
	}
	
	class func test() {
		let obj = AsyncOperation()
		obj.name = "Async Operation"
		
		// completion block should be defined before start() if main() contains sync operations.
		obj.completionBlock = {
			print("\n[Async operation] operation completed")
			AsyncOperation.printStates(operation: obj)
		}
		
		//obj.cancel()
		obj.start()
	}
	
	private class func printStates(operation: Operation) {
		print("[Async operation] isReady -->", operation.isReady)
		print("[Async operation] isExecuting -->", operation.isExecuting)
		print("[Async operation] isCancelled -->", operation.isCancelled)
		print("[Async operation] isFinished -->", operation.isFinished)
	}
}

extension AsyncOperation {
	
	// create a state enum
	enum State: String {
		case ready
		case executing
		case finished
		
		fileprivate var keyPath: String {
			return "is\(self.rawValue.capitalized)"
		}
	}
}
