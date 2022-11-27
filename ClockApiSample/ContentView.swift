//
//  ContentView.swift
//  ClockApiSample
//
//  Created by Toshiharu Imaeda on 2022/11/27.
//

import SwiftUI
import Foundation

struct ContentView: View {
    @State private var string: String = "default"
    @State private var string2: String = "default2"
    @State private var task: Task<Void, Never>?

    var body: some View {
        VStack(spacing: 16) {
            Button("処理開始") {
                if let task {
                    guard task.isCancelled else { return }
                }
                string = "スタート！"
                task = Task {
                    do {
                        // 処理
                        let sequence = start()
                        for try await str in sequence {
                            string += "\n" + str
                        }
                    } catch (let e) {
                        print(e.localizedDescription)
                    }
                }
            }
            Text(string)
            Button("キャンセル") {
                cancel()
            }
            Text(string2)
                .task {
                    do {
                        let clock = SuspendingClock()
                        let duration = try await clock.measure {
                            try await Task.sleep(nanoseconds: 6_000_000_000)
                        }
//                        try await clock.sleep(until: clock.now.advanced(by: .seconds(5)), tolerance: .seconds(0.5))
                        string2 = "5秒経過" + duration.description
                        // スリープしても時間が動き続けている..?
                        print(duration)
                    } catch {

                    }
                }
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

extension ContentView {
    func start() -> AsyncThrowingStream<String, Error> {
        AsyncThrowingStream<String, Error> { continuation in
            Task {
                do {
                    let arr = 0...10
                    for elm in arr {
//                        let clock = ContinuousClock()
                        let clock = SuspendingClock()
                        let deadline = clock.now + .seconds(5)
                        try await clock.sleep(until: deadline)
                        print("!!!")
                        // スリープしても時間が動き続けている..?
                        continuation.yield(elm.description)
                    }
                    continuation.finish()
                } catch(let e) {
                    continuation.finish(throwing: e)
                }
            }
        }
    }

    func cancel() {
        guard let task else { return }
        task.cancel()
        self.task = nil
        string += "\nキャンセルされました"
    }
}
