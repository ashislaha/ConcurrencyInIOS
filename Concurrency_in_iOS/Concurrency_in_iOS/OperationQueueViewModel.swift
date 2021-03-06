//
//  OperationQueuViewModel.swift
//  Concurrency_in_iOS
//
//  Created by Ashis Laha on 07/03/20.
//  Copyright © 2020 Ashis Laha. All rights reserved.
//

import Foundation

struct URLStrings {
	static let google = "https://www.google.com"
	static let apple = "https://www.apple.com"
	static let microsoft = "https://www.microsoft.com/en-in/"
	static let linkedIn = "https://www.linkedin.com"
	static let github = "https://github.com"
}

/*
	define the dependency graph:
		google <-- apple
		apple <-- microsoft
		apple <-- linkedIn
		(microsoft & linkedIn) <-- github
	
*/

enum ArithmeticOperation {
	case add
	case subtract
	case multiplication
	case division
	case none
}

class OperationQueueConcurrencyModel: NSObject {
	
	//MARK:- Approach 1: Operation with sync statements
	
	let operationQueue = OperationQueue()
	var arithmeticModel: [(String, Int)] = [] // update arithemetic model based on arithmetic operations
	let semaphore = DispatchSemaphore(value: 1)
	
	var arithmeticOperation: ArithmeticOperation = .none {
		didSet {
			switch arithmeticOperation {
			case .add: print("add")
			case .subtract: print("subtract")
			case .multiplication: print("multiplication")
			case .division: print("division")
			default: break
			}
		}
	}
	
	func solveConcurrencyOfSyncBlock() {
		
		let additionOperation = BlockOperation {
			self.arithmeticOperation = .add
			//self.arithmeticModel.append(("+", 5+5))
			self.updateModel(input: ("+", 5+5))
		}
		additionOperation.completionBlock = {
			print("addition block completed")
		}
		additionOperation.queuePriority = .high
		additionOperation.cancel() // It will cancel the current operation
		
		let subtractionOperation = BlockOperation {
			self.arithmeticOperation = .subtract
			//self.arithmeticModel.append(("-", 20-5))
			self.updateModel(input: ("-", 20-5))
		}
		subtractionOperation.addObserver(self, forKeyPath: "finished", options: .new, context: nil)
		
		let multiplicationOperation = BlockOperation {
			self.arithmeticOperation = .multiplication
			//self.arithmeticModel.append(("*", 4*5))
			self.updateModel(input: ("*", 4*5))
		}
		
		let divisionOperation = BlockOperation {
			self.arithmeticOperation = .division
			//self.arithmeticModel.append(("/", 50/2))
			self.updateModel(input: ("/", 50/2))
		}
		
		let testOperation = SyncOperation()
		testOperation.completionBlock = {
			print("TestOperation is completed")
			print("TestOperation isFinished --> ", testOperation.isFinished)
		}
		
		// create an operation queue and add them with dependencies if needed
		operationQueue.maxConcurrentOperationCount = 10
		let operations = [testOperation,
						  multiplicationOperation,
						  divisionOperation,
						  additionOperation,
						  subtractionOperation]
		operationQueue.addOperations(operations, waitUntilFinished: false)
	}
	
	private func updateModel(input: (String, Int)) {
		
		print("input =", input)
		
		// semaphore
		semaphore.wait()
		arithmeticModel.append(input)
		
		let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
		print(urls)
		
		print(arithmeticModel)
		semaphore.signal()
		
	}
	
	// Key-Value Observer
	// https://gist.github.com/barbaramartina/94b51cef9782fd5e37133d50c96dc87b
	// https://www.dribin.org/dave/blog/archives/2008/09/24/proper_kvo_usage/
	override func observeValue(forKeyPath keyPath: String?,
							   of object: Any?,
							   change: [NSKeyValueChangeKey : Any]?,
							   context: UnsafeMutableRawPointer?) {
		
		if keyPath == "finished" {
			print("Subtraction operation is completed")
		}
	}

	//MARK:- Approach 2: Operation with Async statements
	
	// solution 1: using Operations and OperationQueue
	func solveConcurrencyWithOperationQueue() {
		
		operationQueue.maxConcurrentOperationCount = 2
		let dispatchGroup = DispatchGroup()
		
		// step1: create operations
		let gitHubOperation = BlockOperation {
			
			
			NetworkLayer.get(urlString: URLStrings.github, successBlock: { (data) in
				print("⚽️ Operation: GitHub Call Success")
				
				
			}) { (error) in
				print("GitHub call failed")
				
			}
		}
		dispatchGroup.enter()
		let microsoftOperation = BlockOperation {
			
			NetworkLayer.get(urlString: URLStrings.microsoft, successBlock: { (data) in
				defer { dispatchGroup.leave() }
				print("⚽️ Operation: Microsoft Call Success")
				
			}) { (error) in
				defer { dispatchGroup.leave() }
				print("Microsoft call failed")
			}
		}
		dispatchGroup.enter()
		let linkedInOperation = BlockOperation {
			
			NetworkLayer.get(urlString: URLStrings.linkedIn, successBlock: { (data) in
				print("⚽️ Operation: LinkedIn Call Success")
				dispatchGroup.leave()
				
			}) { (error) in
				print("LinkedIn call failed")
				dispatchGroup.leave()
			}
		}
		
		let appleOperation = BlockOperation {
			
			
			NetworkLayer.get(urlString: URLStrings.apple, successBlock: { (data) in
				print("⚽️ Operation: Apple Call Success")
				[microsoftOperation, linkedInOperation].forEach {
					self.operationQueue.addOperation($0)
				}
				
				
			}) { (error) in
				print("Apple call failed")
				
			}
		}
		
		
		let googleOperation = BlockOperation {
			
			
			NetworkLayer.get(urlString: URLStrings.google, successBlock: { (data) in
				print("⚽️ Operatoin: Google Call Success")
				
				self.operationQueue.addOperation(appleOperation)
				
			}) { (error) in
				print("Google call failed")
				
			}
			
		}
		googleOperation.completionBlock = {
			print("Google sync block has been executed \n")
		}
		
		
		// step 2: add dependencies
		appleOperation.addDependency(googleOperation)
		microsoftOperation.addDependency(appleOperation)
		linkedInOperation.addDependency(appleOperation)
		[microsoftOperation, linkedInOperation].forEach { gitHubOperation.addDependency($0) }
		
		operationQueue.addOperation(googleOperation)
		
		// step 3: create operation Queue
//		let operations = [googleOperation, appleOperation, microsoftOperation, linkedInOperation, gitHubOperation]
//		operationQueue.addOperations(operations, waitUntilFinished: false)
		
		// step 4: we want to do some operation at the end of completion: Dispatch Group will help here
		dispatchGroup.notify(queue: .main) {
			
			self.operationQueue.addOperation(gitHubOperation)
		}
	}
}
