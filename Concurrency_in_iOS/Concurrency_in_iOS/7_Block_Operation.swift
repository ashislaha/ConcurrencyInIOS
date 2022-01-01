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
		
		let date1 = Date()
		blockOperaiton.start()
		let date2 = Date()
		
		let diff = date1.distance(to: date2)
		print(diff)
	}
	
	class func test() {
		let obj = TestBlockOperation()
		obj.isConcurrentTesting()
	}
	
}
