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

import XCERequirement

// MARK: - After VOID, WITH output

public
extension Given.ObserverConnector where GivenOutput == Void
{
    /**
     Adds subsequent 'GIVEN' clause in Scenario.
     */
    func and<Output>(
        _ specification: String,
        mapState handler: @escaping (GlobalModel) throws -> Output
        ) -> Given.ObserverConnector<Observer, Output>
    {
        let nextGiven = Given(specification) { globalModel, _ in
            
            return try handler(globalModel)
        }
        
        //---
        
        var items = self.previousClauses
        items.append(nextGiven)
        
        //---
        
        return Given.ObserverConnector(
            scenario: scenario,
            when: when,
            previousClauses: items
        )
    }
}

// MARK: - After VOID, NO output

public
extension Given.ObserverConnector where GivenOutput == Void
{
    /**
     Adds subsequent 'GIVEN' clause in Scenario that does NOT return anything.
     */
    func and(
        _ specification: String,
        withState handler: @escaping (GlobalModel) throws -> Void
        ) -> Given.ObserverConnector<Observer, Void>
    {
        let nextGiven = Given(specification) { globalModel, _ in
            
            try handler(globalModel)
            
            //===
            
            return ()
        }
        
        //---
        
        var items = self.previousClauses
        items.append(nextGiven)
        
        //---
        
        return Given.ObserverConnector(
            scenario: scenario,
            when: when,
            previousClauses: items
        )
    }
}

// MARK: - After VOID, Returns Bool

public
extension Given.ObserverConnector where GivenOutput == Void
{
    /**
     Adds subsequent 'GIVEN' clause in Scenario that does NOT return anything.
     */
    func and(
        _ specification: String,
        ifMapState handler: @escaping (GlobalModel) throws -> Bool
        ) -> Given.ObserverConnector<Observer, Void>
    {
        let nextGiven = Given(specification) { globalModel, _ in

            try Require("Handler returns 'true'").isTrue(

                try handler(globalModel)
            )

            //===

            return ()
        }

        //---

        var items = self.previousClauses
        items.append(nextGiven)

        //---

        return Given.ObserverConnector(
            scenario: scenario,
            when: when,
            previousClauses: items
        )
    }
}

// MARK: - WITH output

public
extension Given.ObserverConnector
{
    /**
     Adds subsequent 'GIVEN' clause in Scenario.
     */
    func and<Output>(
        _ specification: String,
        mapInput handler: @escaping (GivenOutput) throws -> Output
        ) -> Given.ObserverConnector<Observer, Output>
    {
        typealias Input = GivenOutput
        
        //---
        
        let nextGiven = Given(specification) { _, previousResult in
            
            let typedPreviousResult =
                
            try Require("Previous result is of type \(Input.self)").isNotNil(
                
                previousResult as? Input
            )
            
            //===
            
            return try handler(typedPreviousResult)
        }
        
        //---
        
        var items = self.previousClauses
        items.append(nextGiven)
        
        //---
        
        return Given.ObserverConnector(
            scenario: scenario,
            when: when,
            previousClauses: items
        )
    }
    
    //===
    
    /**
     Adds subsequent 'GIVEN' clause in Scenario.
     */
    func and<Output>(
        _ specification: String,
        map handler: @escaping (GlobalModel, GivenOutput) throws -> Output
        ) -> Given.ObserverConnector<Observer, Output>
    {
        typealias Input = GivenOutput
        
        //---
        
        let nextGiven = Given(specification) { globalModel, previousResult in
            
            let typedPreviousResult =
                
            try Require("Previous result is of type \(Input.self)").isNotNil(
                
                previousResult as? Input
            )
            
            //===
            
            return try handler(globalModel, typedPreviousResult)
        }
        
        //---
        
        var items = self.previousClauses
        items.append(nextGiven)
        
        //---
        
        return Given.ObserverConnector(
            scenario: scenario,
            when: when,
            previousClauses: items
        )
    }
}

// MARK: - NO output

public
extension Given.ObserverConnector
{
    /**
     Adds subsequent 'GIVEN' clause in Scenario that does NOT return anything.
     */
    func and(
        _ specification: String,
        withInput handler: @escaping (GivenOutput) throws -> Void
        ) -> Given.ObserverConnector<Observer, Void>
    {
        typealias Input = GivenOutput
        
        //---
        
        let nextGiven = Given(specification) { _, previousResult in
            
            let typedPreviousResult =
                
            try Require("Previous result is of type \(Input.self)").isNotNil(
                
                previousResult as? Input
            )
            
            //===
            
            try handler(typedPreviousResult)
            
            //===
            
            return ()
        }
        
        //---
        
        var items = self.previousClauses
        items.append(nextGiven)
        
        //---
        
        return Given.ObserverConnector(
            scenario: scenario,
            when: when,
            previousClauses: items
        )
    }
    
    //===
    
    /**
     Adds subsequent 'GIVEN' clause in Scenario that does NOT return anything.
     */
    func and(
        _ specification: String,
        with handler: @escaping (GlobalModel, GivenOutput) throws -> Void
        ) -> Given.ObserverConnector<Observer, Void>
    {
        typealias Input = GivenOutput
        
        //---
        
        let nextGiven = Given(specification) { globalModel, previousResult in
            
            let typedPreviousResult =
                
            try Require("Previous result is of type \(Input.self)").isNotNil(
                
                previousResult as? Input
            )
            
            //===
            
            try handler(globalModel, typedPreviousResult)
            
            //===
            
            return ()
        }
        
        //---
        
        var items = self.previousClauses
        items.append(nextGiven)
        
        //---
        
        return Given.ObserverConnector(
            scenario: scenario,
            when: when,
            previousClauses: items
        )
    }
}

// MARK: - Returns Bool

public
extension Given.ObserverConnector
{
    /**
     Adds subsequent 'GIVEN' clause in Scenario that does NOT return anything.
     */
    func and(
        _ specification: String,
        ifMapInput handler: @escaping (GivenOutput) throws -> Bool
        ) -> Given.ObserverConnector<Observer, Void>
    {
        typealias Input = GivenOutput

        //---

        let nextGiven = Given(specification) { _, previousResult in

            let typedPreviousResult =

            try Require("Previous result is of type \(Input.self)").isNotNil(

                previousResult as? Input
            )

            //===

            try Require("Handler returns 'true'").isTrue(

                try handler(typedPreviousResult)
            )

            //===

            return ()
        }

        //---

        var items = self.previousClauses
        items.append(nextGiven)

        //---

        return Given.ObserverConnector(
            scenario: scenario,
            when: when,
            previousClauses: items
        )
    }

    //===

    /**
     Adds subsequent 'GIVEN' clause in Scenario that does NOT return anything.
     */
    func and(
        _ specification: String,
        ifMap handler: @escaping (GlobalModel, GivenOutput) throws -> Bool
        ) -> Given.ObserverConnector<Observer, Void>
    {
        typealias Input = GivenOutput

        //---

        let nextGiven = Given(specification) { globalModel, previousResult in

            let typedPreviousResult =

            try Require("Previous result is of type \(Input.self)").isNotNil(

                previousResult as? Input
            )

            //===

            try Require("Handler returns 'true'").isTrue(

                try handler(globalModel, typedPreviousResult)
            )

            //===

            return ()
        }

        //---

        var items = self.previousClauses
        items.append(nextGiven)

        //---

        return Given.ObserverConnector(
            scenario: scenario,
            when: when,
            previousClauses: items
        )
    }
}
