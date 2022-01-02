//
//  7_Block_Operation.swift
//  Concurrency_in_iOS
//
//  Created by Ashis Laha on 01/01/22.
//  Copyright © 2022 Ashis Laha. All rights reserved.
//

import Foundation

class TestBlockOperation {
	
	// How do you know they are executing concurrently.
	// add a delay of 1sec on every task (execution block)
	// if we add 8 tasks and they are executing serially then it must take 8 sec at least but check the execution outcome.
	func isConcurrentTesting() {
		let blockOperaiton = BlockOperation()
		
		// block operation executes block concurrently, not serially. So the order may change
		for i in 1...8 {
			blockOperaiton.addExecutionBlock {
				print("[TestBlockOperation] adding block \(i) in block operation")
				sleep(1)
			}
		}
		
		blockOperaiton.completionBlock = {
			print("[TestBlockOperation] all tasks are completed.")
		}
		
		let date1 = Date()
		blockOperaiton.start()
		let date2 = Date()
		
		let diff = date1.distance(to: date2)
		print(diff)
	}
	
	class func test() {
		let obj = TestBlockOperation()
		obj.isConcurrentTesting()
		
		obj.orderOperations()
	}
	
	
	// I am creating a local variable as we are trying to start 2nd operation on completion of 1st operation.
	private var blockOperation2: BlockOperation?
	
	func orderOperations() {
		let blockOperation1 = BlockOperation {
			print("[BlockOperation] operation 1: Do multiplication / division first")
		}
		
		blockOperation1.completionBlock = {
			print("[BlockOperation] operation 1: Completed")
			//self.blockOperation2?.start()
		}
		
		blockOperation2 = BlockOperation {
			print("[BlockOperation] operation 2: Do addition second")
		}
		
		blockOperation2?.completionBlock = {
			print("[BlockOperation] operation 2: Completed")
		}
		
		blockOperation2?.addDependency(blockOperation1)
		
		// when to start the operations?
		// If the block operations are doing sync operation then we can start sequentially.
		blockOperation1.start()
		blockOperation2?.start()
		
		// If 2nd task is dependent on result of 1st operation then 1st operation is async,
		// then 2nd task should not start immediately, rather than it should start when 1st task is completed.
		//blockOperation1.start()
	}
	
}
