//
//  9_async_await.swift
//  Concurrency_in_iOS
//
//  Created by Ashis Laha on 14/01/22.
//  Copyright © 2022 Ashis Laha. All rights reserved.
//

import Foundation

// ---------------------------------------------------------- //
/// Async and await
// ----------------------------------------------------------//

// we already have multiple options for doing async opertaion
// like DispatchQueue, nested dispatch, dispatch group, operation queue.

// why async / await

// Let's say we want to call mutiple apis in a particular order --> Employees, Projects, Equipments
// If we use only DispatchQueue then we will create a nested closure and solve it
// even if for Operation we need to put the right dependency and call the next api once we receive the result.

// Async await can throw an error/exception like a sync func does. That is extra advantage over async method.

// This can be solved using async await easily

// Case -1: Understand a func having async method internally

@available(iOS 15.0.0, *)
class AsyncAwait {
	
	// Normal func where we used a completion handler to pass the result once the async operation is completed.
	func heartbeatCheck(url: URL, completionHandler: @escaping (Bool) -> Void) {
		
		let task = URLSession.shared.dataTask(with: url) { data, response, error in
			
			guard let httpResponse = response as? HTTPURLResponse,
					let _ = data,
					error == nil
			else {
				completionHandler(false)
				return
			}
			
			let isSuccess = (200...299).contains(httpResponse.statusCode)
			completionHandler(isSuccess)
		}
		task.resume()
	}
	
	// redefine the above func with async (no need of @escaping closure)
	// Async task can throw an exception which is not possible for completion handler.
	func heartbeatCheck(url: URL) async -> Bool {
		
		var isServerON = false
		do {
			
			let (_/* data */, serverResponse) = try await URLSession.shared.data(from: url, delegate: nil)
			
			guard let httpResponse = serverResponse as? HTTPURLResponse else { return false }
			isServerON = (200...299).contains(httpResponse.statusCode)
			
		} catch let error {
			print(error)
		}
		
		return isServerON
	}
	
	class func test() {
		let obj = AsyncAwait()
		let url = URL(string: "https://www.microsoft.com")!
		obj.heartbeatCheck(url: url) { serverOn in
			print("[with CompletionHandler] Microsoft server is ON: \(serverOn)")
		}
		
		// we must call a async func inside an another async func.
		// to avoid this we can use Task closure.
		Task {
			print("is main thread", Thread.isMainThread)
			let isServerOn = await obj.heartbeatCheck(url: url)
			print("\n\n[Async Await] Microsoft server is ON: \(isServerOn)")
			
			if isServerOn {
				let githubURL = URL(string: "https://www.github.com")!
				print("if MS heartbeat is ON, check github heartbeat:", await obj.heartbeatCheck(url: githubURL))
			}
		}
	}
}

