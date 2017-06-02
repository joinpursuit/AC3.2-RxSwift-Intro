
import UIKit
import RxSwift

example(of: "just") {
  // .just() - Returns an observable sequence that contains a single element.
  
  // Array<Element>
  // let array = [1, 2, 3, 4] <-- Array<Int>
  // let other = ["a", "b"] <-- Array<String>
  
  // Observer : RX :: Functions : Swift
  let observable = Observable.just("Hello, World!")
  // Observable<String>
  
  // subscribe takes a closure that receives the emitted event and executes each time this event is emitted.
  observable.subscribe({ (event: Event<String>) in
    
    // print out each event as it is emitted
    print(event)
    // result ends up being a single next() event with the string sequence
    // followed by the completed() event
    
    // when either the completed() or the error() events occur, the observed
    // sequence can no longer emit more events
  })
}


// the "of" observer
example(of: "of") {
  let observable = Observable.of(1, 2, 3, 4, 5)
  
  // result of this is 3 next() events
  // followed by the completed() event
  observable.subscribe {
    // $0 -> Event<Int>
    print($0)
  }
  
  /*
   observable.subscribe(onNext: (Int) -> Void?,
   onError: (Error) -> Void?,
   onCompleted: () -> Void?,
   onDisposed: () -> Void?)
   */
  
  observable
    .subscribe(onNext: {
      print($0)
    }, onCompleted: {
      print("other subscription completed")
    })
  
}

example(of: "from") {
  let disposeBag = DisposeBag()
  
  /*
   subscribe() returns a type of Disposable. This is an object
   that conforms to a particular protocol to indicate it can be disposed.
   */
  let observable = Observable.from([1, 2, 3, 4, 5, 6])
  let subscription: Disposable = observable.subscribe {
    print($0)
  }
  subscription.disposed(by: disposeBag)
  
  let subscription2: Disposable = observable.subscribe {
    print("This is the other subscribe", $0)
  }
  
  observable
    .subscribe { print("checking on another sub", $0) }
    .disposed(by: disposeBag)
  
  // disposing of a subscription causes the underlying sequence to emit a completed event and to terminate. The sequence here was determined ahead of time, and so the completed event gets called automatically. However, in most cases you want the observer to continually emit events.
  
  // To remove a subscription properly, you'd need to call .dispose() on the Disposable object. But convention is to add observables to a DisposeBag and then to call dispose on all items in the DisposeBag in the deinit of a class.
}

example(of: "error") {
  enum MyError: Error {
    case testError
  }
  
  Observable<Void>.error(MyError.testError)
    .subscribe(onError: { (error: Error) in
      print(error)
    })
  
}

/*
 Subject in RxSwift
 - Subject: acts as both an observable sequence (can be subscribed to) and observer (to add new elements, which will be emitted to the subject’s subscribers.
 
 1. PublishSubject
 - you need to specify the type of the PublishSubject on init
 - subscribers only receives events after they subscribe
 - but still receives onComplete and onError
 
 
 2. BehaviorSubject
 - subscriber receives the last event emitted, or the initialized value
 - but they still send/receive onComplete and onError
 
 
 3. ReplaySubject
 - receives a buffer of previous events, so it could the last n-number of events on a stream
 - receives them in the same order they occurred.
 
 
 4. Variable
 - Wraps a BehaviorSubject
 - Replays most recent next() event
 - Will not emit error event
 - Automatically completes when it is about to be deallocated
 - Uses dot-syntax to get or set latest value
 */


// Only gets the events going forward
example(of: "PublishSubject") {
  
  let disposeBag: DisposeBag = DisposeBag()
  
  // <Int> describes the .value of the Event(s) this observable stream will emit
  // This is analogous to saying that
  //
  // let values = [1, 2, 3].map { $0 * $0 }
  //
  // values would be Array<Int> because map returns a type of Array<T> where
  // T is the Element type of result of the map closure
  
  let observable = PublishSubject<Int>()
  observable
    .subscribe {
      print("get all of them", $0)
    }
    .disposed(by: disposeBag)
  
  observable.onNext(1)
  observable.onNext(2)
  observable.onNext(3)
  
  // this only receives events that come after subscription
  observable
    .subscribe(onNext: {
      print($0)
    }, onCompleted: {
      print("Stream completed")
    })
    .disposed(by: disposeBag)
  
  observable.onNext(4)
  observable.onNext(5)
  
  // PublishSubjects do not send a complete() event automatically, you have to
  // specifically call it
  observable.onCompleted()
}

// Sends subscribers either the most recent event, or the initial value of the stream
example(of: "BehaviorSubject") {
  
  let disposeBag = DisposeBag()
  
  // doesn't need to be given an explicit Element type, it gets inferred from the initial value
  // BehaviorSubject<String>
  let observable = BehaviorSubject(value: "Hello")
  observable.onNext("World")
  observable.onNext("Nice to meet you")
  
  // this only receives the initial value OR the most recent one
  observable
    .subscribe {
      print($0)
    }
    .disposed(by: disposeBag)
}

// It replays a buffer of events, you determine the size of the buffer
example(of: "ReplaySubject") {
  
  let disposeBag = DisposeBag()
  let observable = ReplaySubject<Int>.create(bufferSize: 4)
  observable.onNext(1)
  observable.onNext(2)
  observable.onNext(3)
  observable.onNext(4)
  observable.onNext(5)
  observable.onNext(6)
  observable.onNext(7)
  
  observable.subscribe {
    print($0)
    }.disposed(by: disposeBag)
  
  observable
    .subscribe(onNext: {
      print($0)
    })
    .disposed(by: disposeBag)
}

// Wrapper on a BehaviorSubject
example(of: "Variable") {
  let disposeBag = DisposeBag()
  
  // Variable<String>
  let observable = Variable("cat")
  
  // Observable<String>
  let behaviorSubject = observable.asObservable()
  observable.value = "dog"
  //observable.value = "mouse"
  //observable.value = "kitten"
  
  // only "kitten" gets outputted because it was the last value that was emitted before the subscription occured.
  // but all subsequent events get outputted as well because they come after the subscription has occurred
  behaviorSubject.subscribe {
    print($0)
  }
  
  observable.value = "bird"
  observable.value = "snake"
  observable.value = "rabbit"
  
}

/*
 It's your party, and you're opening presents. But your mother leaves the room to get cupcakes,
 and you open three presents.
 
 - Your friends that are present for you receiving events since the start, just observe the events the entire time you open presents. They're subscribed to your opening present observations
 - Your mother requesting info on the presents opened is like a *ReplaySubject*: she wants you to replay the present you received. In this case the presents are the events in your opening observation
 - Your friend that comes in and asks about your previous presents, you give him the last one you opened to shut him up and continue. Your friend is a BehaviorSubject, receiving info on the last present you got, plus everything going forward
 - Your other not so good friend just comes in for the cake/ambience. So they don't care about what has already occurred, but they pay attention to all further present opening events. They are like a PublishSubject
 */

example(of: "map") {
  let disposeBag = DisposeBag()
  Observable.of(1, 2, 3, 10) // returns Observable<Int>
    .map{ $0 * $0 } // Observable<Int> still
    .subscribe(onNext:  { // now we subscribe to the result of the map() func call, which is Observable<Int>
      print($0)
    })
    .disposed(by: disposeBag)
}

example(of: "filter") {
  let disposeBag = DisposeBag()
  Observable.generate(initialState: 0,
                      condition: { $0 < 100 },
                      iterate:   { $0 + 1} )
    .filter{ $0 % 2 == 0 }
    .filter{ $0 % 4 == 0 }
    .map{ $0 + 1000 }
    .subscribe(onNext: { print($0) })
    .disposed(by: disposeBag)
}

example(of: "distinctUntilChanged") {
  
  let disposeBag = DisposeBag()
  let observable = PublishSubject<String>()
  
  
  // does order matter? yes: try moving around the .map call before/after the distinctUntilChanged function
  observable
    //.map{ $0.lowercased() }
    .distinctUntilChanged()
    .map{ $0.lowercased() }
    .subscribe(onNext:  {
      print($0)
    })
    .disposed(by: disposeBag)
  
  observable.onNext("Hello")
  observable.onNext("HELLO")
  observable.onNext("hello")
  observable.onNext("There")
  observable.onNext("There")
}

// continue to observe events until a specific predicate is met
example(of: "takeWhile") {
  
  let disposeBag = DisposeBag()
  Observable.generate(initialState: 1,
                      condition: { $0 < 10 },
                      iterate: { $0 + 1 })
    .takeWhile { $0 < 5 }
    .subscribe(onNext: {
      print($0)
    })
    .disposed(by: disposeBag)
}

// scan: like reduce in that it performs an aggregate function on a sequence of values. but it differs because you can access each step of that aggregation as an observable object. Reduce just returns the since obversable with the aggregated value
// buffer: gathers emitted events based on time or a specified number
example(of: "scan & buffer") {
  let disposeBag = DisposeBag()
  
  let observable = PublishSubject<Int>()
  /*
  observable
    .buffer(timeSpan: 0.0,
            count: 2,
            scheduler: MainScheduler.instance)
    .subscribe(onNext: {
      print($0)
    })
    .disposed(by: disposeBag)
 */
  
  // it's all about what function you 
  // use on the returned value of the prior function
  observable
    .scan(501, accumulator: -)
    .buffer(timeSpan: 0.0, count: 3, scheduler: MainScheduler.instance)
    .map{
      print($0)
      return $0.reduce(0, +)
    }
    .subscribe(onNext: { print($0) })
  
  observable.onNext(5)
  observable.onNext(9)
  observable.onNext(22)
    /*
    .buffer(timeSpan: 0.0, count: 3, scheduler: MainScheduler.instance)
    .map{ // [Int]
      print($0)
      return $0.reduce(0, +)
    }
    .subscribe(onNext: {
      print("Elements =>", $0)
    })
    .disposed(by: disposeBag)
 
  observable.onNext(10)
  observable.onNext(20)
  observable.onNext(30)
  
  observable.onNext(40)
  observable.onNext(50)
  observable.onNext(60)
  
  observable.onNext(500)
  observable.onNext(40)
  observable.onNext(40)
 */
}





// flatMap, flatMapLast
