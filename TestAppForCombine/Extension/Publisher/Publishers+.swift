//
//  Publishers+.swift
//  TestAppForCombine
//
//  Created by Hyun A Song on 5/26/24.
//

import Combine
import Dispatch

// MARK: - DispatchTimer
extension Publishers {
  // struct인 이유: 의도치 않은 상태 공유 방지, 불변성, 캡슐화, Value Witness를 통한 성능 이점
  struct DispatchTimer: Publisher {
    // Publisher Protocol 필수구현 - Output
    typealias Output = DispatchTime
    typealias Failure = Never
    let configuration: DispatchTimerConfiguration
    
    init(configuration: DispatchTimerConfiguration) {
      self.configuration = configuration
    }
    
    // Publisher Protocol 필수구현 - receive(subscriber:)
    func receive<S: Subscriber>(subscriber: S)
    where Failure == S.Failure, Output == S.Input {
      let subscription = DispatchTimerSubscription(
        subscriber: subscriber,
        configuration: configuration
      )
      subscriber.receive(subscription: subscription)
    }
  }
  
  // Publisher가 Subscriber에게 줄 Subscription 만들기~
  private final class DispatchTimerSubscription<S: Subscriber>: Subscription where S.Input == DispatchTime {
    let configuration: DispatchTimerConfiguration
    // times: leeway를 위한 값, publisher가 만들 수 있는 최대 값 갯수
    var times: Subscribers.Demand
    // requested: 값을 보낸 횟수
    /*
     .none == Demand.max(0)
     max(_:) -> Subscribers.Demand: element의 최대 수를 파라미터로 받음. 음수가 들어오면 에러
     */
    var requested: Subscribers.Demand = .none
    var subscriber: S?
    var source: DispatchSourceTimer? = nil
    
    init(subscriber: S,
         configuration: DispatchTimerConfiguration) {
      self.configuration = configuration
      self.subscriber = subscriber
      self.times = configuration.times
    }
    
    // Subscription Protocol(Cancellable Protocol에서 상속) 필수구현 - request(_:)
    func request(_ demand: Subscribers.Demand) {
      guard times > .none else {
        subscriber?.receive(completion: .finished)
        return
      }
      
      requested += demand
      
      if source == nil, requested > .none {
        let source = DispatchSource.makeTimerSource(queue: configuration.queue)
        // 새로운 값 생성
        source.schedule(deadline: .now() + configuration.interval,
                        repeating: configuration.interval,
                        leeway: configuration.leeway)
        
        // 새로운 값이 방출될 때마다 실행
        source.setEventHandler { [weak self] in
          guard let self = self,
                self.requested > .none else { return }
          self.requested -= .max(1)
          self.times -= .max(1)
          _ = self.subscriber?.receive(.now())
          if self.times == .none {
            self.subscriber?.receive(completion: .finished)
          }
        }
        
        self.source = source
        source.activate()
      }
    }
    
    // Subscription Protocol 필수구현 - cancel()
    func cancel() {
      /*
       DispatchSourceTimer를 nil하면 취소가 되지만, 구독 실행을 중지할 것이 아니면 하지 않음
       subscriber를 nil로 해도 Subscription 범위 내에서 해제하면 불필요한 객체를 메모리에 유지하지 않음
       */
      source = nil
      subscriber = nil
    }
  }
  
  // MARK: - Static Function -> Publisher 객체 생성하는 함수
  //  static func timer(queue: DispatchQueue? = nil,
  //                    interval: DispatchTimeInterval,
  //                    leeway: DispatchTimeInterval = .nanoseconds(0),
  //                    times: Subscribers.Demand = .unlimited) -> Publishers.DispatchTimer {
  //    return Publishers.DispatchTimer(
  //      configuration: .init(queue: queue,
  //                           interval: interval,
  //                           leeway: leeway,
  //                           times: times)
  //    )
  //  }
}
