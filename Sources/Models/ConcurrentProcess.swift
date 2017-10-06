/*

 MIT License

 Copyright (c) 2016 Maxim Khatskevich (maxim@khatskevi.ch)

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.

 */

import Foundation

import XCEUniFlow
import XCERequirement
import XCEOperationFlow

//===

public
protocol ConcurrentProcessProxy
{
    associatedtype Input
    associatedtype Result
}

//===

public
extension ConcurrentProcessProxy
{
    typealias Real = M.ConcurrentProcess<Input, Result>

    typealias Idle = Real.Idle
    typealias Running = Real.Running
    typealias Failed = Real.Failed
    typealias Succeeded = Real.Succeeded

    //===

    static
    func setup() -> Action
    {
        return Real.setup()
    }

    static
    func reset() -> Action
    {
        return Real.reset()
    }
}

//===

public
extension M
{
    public
    enum ConcurrentProcess<Input, Result>: Model, NoBindings
    {
        public
        struct Idle: StateAuto
        {
            public
            typealias Parent = ConcurrentProcess<Input, Result>

            public
            init() { }
        }

        public
        struct Running: State
        {
            public
            typealias Parent = ConcurrentProcess<Input, Result>

            public
            let startedAt = Date()

            public
            let processId: UUID

            public
            let input: Input

            public
            let flow: OperationFlow.ActiveProxy
        }

        public
        struct Failed: State
        {
            public
            typealias Parent = ConcurrentProcess<Input, Result>

            public
            let input: Input

            public
            let error: Error
        }

        public
        struct Succeeded: State
        {
            public
            typealias Parent = ConcurrentProcess<Input, Result>

            public
            let input: Input

            public
            let result: Result
        }
    }
}

// MARK: - Actions

public
extension M.ConcurrentProcess
{
    static
    func setup() -> Action
    {
        return initialize.Into<Idle>.automatically()
    }

    //===

    public
    typealias Implementation =
        (Input, UUID, @escaping SubmitAction) -> OperationFlow

    //===

    static
    func setupAndStart(
        with input: Input,
        run: @escaping Implementation,
        minDelay: TimeInterval = 0
        ) -> Action
    {
        return initialize.Into<Running>.via { become, submit in

            let processId = UUID()

            become << Running(
                processId: processId,
                input: input,
                flow: run(input, processId, submit).proxy
            )
        }
    }

    //===

    static
    func start(
        with input: Input,
        run: @escaping Implementation,
        minDelay: TimeInterval = 0
        ) -> Action
    {
        return transition.Into<Running>.via(same: .ok) { globalModel, become, submit in

            if
                let running = try? Running.from(globalModel)
            {
                try? running.flow.cancel()

                //---

                try Require("Threshold has been passed").isTrue(

                    minDelay <= Date().timeIntervalSince(running.startedAt)
                )
            }

            //---

            let processId = UUID()

            become << Running(
                processId: processId,
                input: input,
                flow: run(input, processId, submit).proxy
            )
        }
    }

    //===

    static
    func fail(with processId: UUID, error: Error) -> Action
    {
        return transition.Between<Running, Failed>.via { running, become, _ in

            try Require("This is the most recent process result.").isTrue(

                running.processId == processId
            )

            //---

            become << Failed(input: running.input, error: error)
        }
    }

    //===

    enum AfterFinishAction
    {
        case none, remove, reset
    }

    //===

    static
    func finish(
        with processId: UUID,
        result: Result,
        next: AfterFinishAction = .none
        ) -> Action
    {
        return transition.Between<Running, Succeeded>.via { running, become, submit in

            try Require("This is the most recent process result.").isTrue(

                running.processId == processId
            )

            //---

            become << Succeeded(input: running.input, result: result)

            //---

            switch next
            {
                case .remove:
                    submit << deinitialize.From<Succeeded>.automatically()

                case .reset:
                    submit << reset

                default:
                    break
            }
        }
    }

    //===

    static
    func reset() -> Action
    {
        return transition.Into<Idle>.automatically(same: .no)
    }
}
