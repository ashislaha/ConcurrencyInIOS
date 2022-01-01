//
//  ViewController.swift
//  Concurrency_in_iOS
//
//  Created by Ashis Laha on 02/03/20.
//  Copyright © 2020 Ashis Laha. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

	override func viewDidLoad() {
		super.viewDidLoad()
		
		/*
		let concurrentModel = OperationQueueConcurrencyModel()
		// Sync
		concurrentModel.solveConcurrencyOfSyncBlock()
		
		// Async
		// approach - 1
		concurrentModel.solveConcurrencyWithOperationQueue()
		
		// approach - 2
		let gcdConcurrentModel = GCDConcurrencyModel()
		gcdConcurrentModel.solveConcurrencyWithGCD()
		*/
		
		// Test Queue
		//let testQueue = TestQueue()
		//testQueue.testSerialQueue()
		//testQueue.testConcurrentQueue()
		//print(testQueue.messages)
		
		//let raceCondition = RaceCondition()
		//raceCondition.test()
		
		//let priorityInversion = ProirityInversion()
		//priorityInversion.test()
		
		//let testBlockOperation = TestBlockOperation()
		//testBlockOperation.test()
		//testBlockOperation.testIsConcurrent()
		
		// Test - 1: Time profile:
		//ConcurrencyTimeProfile.test()
		
		// Test - 2: Sync and Async operations on dispatchQueue
		//DispatchQueueSyncAsyncOperation.test()
		
		// Test - 3: DispatchQueueQOS and understanding of QOS priority changes.
		//DispatchQueueQOS.test()
		
		// Test - 4: Handling mulitple tasks (DispatchWorkItem) in a dispatchQueue.
		//DispatchGroupWithWorkItems.test()
		
		// Test - 5: Handling race-condition
		//RaceCondition.test()
		
		// Test - 6: Sync Operation
		//SyncOperation.test()
		
		// Test - 7: Sync Operation
		//AsyncOperation.test()
		
		// Test - 8: Block Operation
		TestBlockOperation.test()
	}
}

