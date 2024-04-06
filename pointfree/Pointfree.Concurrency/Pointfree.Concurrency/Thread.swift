import Foundation

func threadBasics() {
    Thread.detachNewThread { print("1", Thread.current) }
    Thread.detachNewThread { print("2", Thread.current) }
    Thread.detachNewThread { print("3", Thread.current) }
    Thread.detachNewThread { print("4", Thread.current) }
    Thread.detachNewThread { print("5", Thread.current) }
    
    Thread.sleep(forTimeInterval: 1.1)
    print("!")
}

func priorityAndCancelation() {
    let thread = Thread {
        let start = Date()
        defer { print("Finished in: \(Date().timeIntervalSince(start))") }
        
        Thread.sleep(forTimeInterval: 1)
        guard !Thread.current.isCancelled else {
            print("Canceled")
            return
        }
        print(Thread.current)
    }
    thread.threadPriority = 0.75
    thread.start()
    Thread.sleep(forTimeInterval: 0.1)
    thread.cancel()
    
    Thread.sleep(forTimeInterval: 1.1)
    print("!")
}

func threadDictionaries() {
    func makeDatabaseRequest() {
        let requestId = Thread.current.threadDictionary["requestId"] as! UUID
        print(requestId, "Making database request")
        Thread.sleep(forTimeInterval: 0.5)
        print(requestId, "Finished database  request")
    }

    func makeNetworkRequest() {
        let requestId = Thread.current.threadDictionary["requestId"] as! UUID
        print(requestId, "Making network request")
        Thread.sleep(forTimeInterval: 0.5)
        print(requestId, "Finished network request")
    }

    func response(for request: URLRequest) -> HTTPURLResponse {
        let requestId = Thread.current.threadDictionary["requestId"] as! UUID
        
        let start = Date()
        defer { print(requestId, "Finished in", Date().timeIntervalSince(start)) }

        makeDatabaseRequest()
        makeNetworkRequest()
        
        return .init()
    }

    let thread = Thread {
        _ = response(for: .init(url: .init(string: "http://rio-engieiro.com")!))
    }

    thread.threadDictionary["requestId"] = UUID()
    thread.start()

    Thread.sleep(forTimeInterval: 1.1)
}

func problemsCoordination() {
    func makeDatabaseRequest() {
        let requestId = Thread.current.threadDictionary["requestId"] as! UUID
        print(requestId, "Making database request")
        Thread.sleep(forTimeInterval: 0.5)
        print(requestId, "Finished database  request")
    }
    
    func makeNetworkRequest() {
        let requestId = Thread.current.threadDictionary["requestId"] as! UUID
        print(requestId, "Making network request")
        Thread.sleep(forTimeInterval: 0.5)
        print(requestId, "Finished network request")
    }
    
    func response(for request: URLRequest) -> HTTPURLResponse {
        let requestId = Thread.current.threadDictionary["requestId"] as! UUID
        
        let start = Date()
        defer { print(requestId, "Finished in", Date().timeIntervalSince(start)) }
        
        let databaseQueryThread = Thread { makeDatabaseRequest() }
        databaseQueryThread.threadDictionary.addEntries(from: Thread.current.threadDictionary as! [AnyHashable: Any])
        databaseQueryThread.start()
        
        let networkRequestThread = Thread { makeNetworkRequest() }
        networkRequestThread.threadDictionary.addEntries(from: Thread.current.threadDictionary as! [AnyHashable: Any])
        networkRequestThread.start()
        
        while !databaseQueryThread.isFinished || !networkRequestThread.isFinished {
            Thread.sleep(forTimeInterval: 0.1)
        }
        
        return .init()
    }
    
    let thread = Thread {
        _ = response(for: .init(url: .init(string: "http://rio-engieiro.com")!))
    }
    
    thread.threadDictionary["requestId"] = UUID()
    thread.start()
    
    Thread.sleep(forTimeInterval: 1.1)
}

func problemExpensiveness() {
    let workCount = 1_000
    
    for n in 0..<workCount {
        Thread.detachNewThread {
            print(n, Thread.current)
            while true {}
        }
    }
    
    func isPrime(_ number: Int) -> Bool {
        if number <= 1 { return false }
        if number <= 3 { return true }
        for i in 2...Int(sqrtf(Float(number))) {
            if number % i == 0 { return false }
        }
        return true
    }
    
    func nthPrime(_ n: Int) {
        let start = Date()
        var primeCount = 0
        var prime = 2
        while primeCount < n {
            defer { prime += 1 }
            if isPrime(prime) {
                primeCount += 1
            }
        }
        print("\(n)th prime", prime - 1, "time", Date().timeIntervalSince(start))
    }
    
    Thread.detachNewThread {
        print("Starting prime thread")
        nthPrime(50_000)
    }
    
    Thread.sleep(forTimeInterval: 30)
}

func problemDataRaces() {
    let workCount = 1_000
    
    final class Counter {
        var count = 0
    }
    let counter = Counter()
    
    for _ in 0..<workCount {
        Thread.detachNewThread {
            Thread.sleep(forTimeInterval: 0.01)
            counter.count += 1
        }
    }
    
    Thread.sleep(forTimeInterval: 0.5)
    print("count", counter.count)
}

func solveDataRaceWithLockingInMethod() {
    let workCount = 1_000
    
    final class Counter {
        private let lock = NSLock()
        private(set) var count = 0
        func increment() {
            lock.lock()
            defer { lock.unlock() }
            count += 1
        }
    }
    let counter = Counter()
    
    for _ in 0..<workCount {
        Thread.detachNewThread {
            Thread.sleep(forTimeInterval: 0.01)
            counter.increment()
        }
    }
    
    Thread.sleep(forTimeInterval: 0.5)
    print("count", counter.count)
}

func solveDataRacesWithLockingModifications() {
    let workCount = 1_000
    
    final class Counter {
        private let lock = NSLock()
        var count = 0
        func modify(work: (Counter) -> Void) {
            lock.lock()
            defer { lock.unlock() }
            work(self)
        }
    }
    let counter = Counter()
    
    for _ in 0..<workCount {
        Thread.detachNewThread {
            Thread.sleep(forTimeInterval: 0.01)
            counter.modify {
                $0.count += 1
            }
        }
    }
    
    Thread.sleep(forTimeInterval: 0.5)
    print("count", counter.count)
}

func tryingToFixDataRacesByLockingGetterSetter() {
    let workCount = 1_000
    
    final class Counter {
        private let lock = NSLock()
        private var _count = 0
        var count: Int {
            get {
                lock.lock()
                defer { lock.unlock() }
                return _count
            }
            set {
                lock.lock()
                defer { lock.unlock() }
                _count = newValue
            }
        }
    }
    let counter = Counter()
    
    for _ in 0..<workCount {
        Thread.detachNewThread {
            Thread.sleep(forTimeInterval: 0.01)
            counter.count += 1
        }
    }
    
    Thread.sleep(forTimeInterval: 0.5)
    print("count", counter.count)
}

func tryingToFixDataRacesByReadingModifying() {
    let workCount = 1_000
    
    final class Counter {
        private let lock = NSLock()
        private var _count = 0
        var count: Int {
            _read {
                lock.lock()
                defer { lock.unlock() }
                yield _count
            }
            _modify {
                lock.lock()
                defer { lock.unlock() }
                yield &_count
            }
        }
    }
    let counter = Counter()
    
    for _ in 0..<workCount {
        Thread.detachNewThread {
            Thread.sleep(forTimeInterval: 0.01)
            counter.count += 1 // works fine
            counter.count += 1 + counter.count / 100 // won't work as expected because cannot consider this as a single transaction
        }
    }
    
    Thread.sleep(forTimeInterval: 0.5)
    print("count", counter.count)
}
