//
//  ShareReplaySubscription.swift
//  TestAppForCombine
//
//  Created by Hyun A Song on 5/26/24.
//

import Combine
import Foundation

/*
 Subscription 구현
 - Subscription 프로토콜 준수
 - Subscriber의 요구와 취소에 대응
 - 모든 Subscriber는 동일 인스턴스에 접근해야함 -> class타입으로 Subscription 생성
 */
fileprivate final class ShareReplaySubscription<Output, Failure: Error>: Subscription {
  // 최대 용량
  let capacity: Int
  // Subscriber에 대한 참조 유지
  var subscriber: AnySubscriber<Output,Failure>? = nil
  // Publisher가 Subscriber로 부터 받는 요구를 추적 -> 요청된 값의 수를 정확하게 전달
  var demand: Subscribers.Demand = .none
  // 값을 공유, 값을 호출, Subcriber에게 전달 혹은 버려지는 변수 값들을 순차적으로 발생했는지 확인
  var buffer: [Output]
  // 새 Subscriber가 값을 요청하면, 바로 전달할 수 있도록 completion 유지
  var completion: Subscribers.Completion<Failure>? = nil
  
  init<S>(
    subscriber: S,
    replay: [Output],
    capacity: Int,
    completion: Subscribers.Completion<Failure>?
  ) where S: Subscriber, Failure == S.Failure, Output == S.Input {
    self.subscriber = AnySubscriber(subscriber)
    // Publisher의 현재 버퍼, 최대 용량, completion을 저장
    self.buffer = replay
    self.capacity = capacity
    self.completion = completion
  }
  
  /*
   Subscription의 필수 구현 함수
   Subscriber와 Publisher의 중간다리
   Subscriber가 Publisher에게 새 값을 내보내라고 알리는 것
   */
  func request(_ demand: Subscribers.Demand) {
    if demand != .none {
      self.demand += demand
    }
    emitAsNeeded()
  }
  
  func cancel() {
    complete(with: .finished)
  }
  
  /*
   Publisher에서 더 많은 값을 보내는데 사용
   emitAsNeeded() -> 버퍼에 최대 용량을 추가
   */
  func receive(_ input: Output) {
    guard subscriber != nil else { return }
    buffer.append(input)
    if buffer.count > capacity {
      buffer.removeFirst()
    }
    emitAsNeeded()
  }
  
  // 이벤트를 수락하고 모든 리소스를 제거, Publisher가 완료하고 완료를 보낼 때 호출 됨
  func receive(completion: Subscribers.Completion<Failure>) {
    guard let subscriber = subscriber else { return }
    self.subscriber = nil
    self.buffer.removeAll()
    subscriber.receive(completion: completion)
  }
  
  // Publisher에게 완료를 전달
  private func complete(with completion: Subscribers.Completion<Failure>) {
    guard let subscriber = subscriber else { return }
    self.subscriber = nil
    self.completion = nil
    self.buffer.removeAll()
    subscriber.receive(completion: completion)
  }
  
  // Subscriber가 존재하는지 확인, Demand가 존재하고, buffer가 있는 한 값을 보냄
  private func emitAsNeeded() {
    guard let subscriber = subscriber else { return }
    while self.demand > .none && !buffer.isEmpty {
      self.demand -= .max(1)
      let nextDemand = subscriber.receive(buffer.removeFirst())
      if nextDemand != .none {
        self.demand += nextDemand
      }
    }
    if let completion = completion {
      complete(with: completion)
    }
  }
}

/*
 fileprivate으로 구현된 ShareReplaySubscription을 위한 Publisher
 
 */
extension Publishers {
  final class ShareReplay<Upstream: Publisher>: Publisher {
    typealias Output = Upstream.Output
    typealias Failure = Upstream.Failure
    
    private let lock = NSRecursiveLock()
    private let upstream: Upstream
    private let capacity: Int
    private var replay = [Output]()
    private var subscriptions = [
      ShareReplaySubscription<Output, Failure>
    ]()
    private var completion: Subscribers.Completion<Failure>? = nil
    
    init(upstream: Upstream, capacity: Int) {
      self.upstream = upstream
      self.capacity = capacity
    }
    
    private func relay(_ value: Output) {
      lock.lock()
      defer { lock.unlock() }
      
      guard completion == nil else { return }
      
      replay.append(value)
      
      if replay.count > capacity {
        replay.removeFirst()
      }
      
      subscriptions.forEach {
        $0.receive(value)
      }
    }
    
    private func complete(_ completion: Subscribers.Completion<Failure>) {
      lock.lock()
      defer { lock.unlock() }
      self.completion = completion
      subscriptions.forEach {
        $0.receive(completion: completion)
      }
    }
    
    func receive<S: Subscriber>(subscriber: S) where Failure == S.Failure, Output == S.Input {
      lock.lock()
      defer { lock.unlock() }
      
      let subscription = ShareReplaySubscription(
        subscriber: subscriber,
        replay: replay,
        capacity: capacity,
        completion: completion
      )
      subscriptions.append(subscription)
      subscriber.receive(subscription: subscription)
      
      guard subscriptions.count == 1 else { return }
      let sink = AnySubscriber(
        receiveSubscription: { subscription in
          subscription.request(.unlimited)
        },
        receiveValue: { [weak self] (value: Output) ->Subscribers.Demand in
          self?.relay(value)
          return .none
        },
        receiveCompletion: { [weak self] in
          self?.complete($0)
        }
      )
      upstream.subscribe(sink)
    }
  }
}

extension Publisher {
  func shareReplay(capacity: Int = .max) -> Publishers.ShareReplay<Self> {
    return Publishers.ShareReplay(upstream: self, capacity: capacity)
  }
}
