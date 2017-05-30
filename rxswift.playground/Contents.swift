
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
