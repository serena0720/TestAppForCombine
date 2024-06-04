//
//  DispatchTimerConfiguration.swift
//  TestAppForCombine
//
//  Created by Hyun A Song on 5/26/24.
//

import Dispatch
import Combine

struct DispatchTimerConfiguration {
  let queue: DispatchQueue?
  let interval: DispatchTimeInterval
  let leeway: DispatchTimeInterval
  let times: Subscribers.Demand
}
