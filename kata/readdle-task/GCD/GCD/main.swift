//
//  main.swift
//  GCD
//
//  Created by Volodymyr Myroniuk on 09.03.2024.
//

import Foundation

var sharedData = [String]()

let queue = DispatchQueue(label: "com.GCD", attributes: .concurrent)

let addSemaphore = DispatchSemaphore(value: 1)
let readSemaphore = DispatchSemaphore(value: 0)
let removeSemaphore = DispatchSemaphore(value: 0)

let maxReadersCount = 5
var readersCounter = 0
let readersCounterLock = NSLock()

queue.async {
    let symbols = ["A", "B", "C"]
    var index = 0
    
    while true {
        let symbol = symbols[index]
        index = (index + 1) % symbols.count
        
        addSemaphore.wait()
        
        sharedData.append(symbol)
        print("Thread 1 added symbol: \(symbol)")
        
        (0..<maxReadersCount).forEach { _ in readSemaphore.signal() }
    }
}

for readerNumber in 2...maxReadersCount + 1 {
    queue.async {
        while true {
            readSemaphore.wait()
            
            if let symbol = sharedData.first {
                print("Thread \(readerNumber) read symbol: \(symbol)")
            }
            
            readersCounterLock.lock()
            readersCounter = (readersCounter + 1) % maxReadersCount
            if readersCounter == 0 { removeSemaphore.signal() }
            readersCounterLock.unlock()
        }
    }
}

queue.async {
    while true {
        removeSemaphore.wait()
        
        if !sharedData.isEmpty {
            print("Thread \(maxReadersCount + 2) removed symbol: \(sharedData.removeFirst())")
        }
        
        addSemaphore.signal()
    }
}

RunLoop.current.run(mode: .default, before: .distantFuture)
