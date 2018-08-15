// Learn more about F# at http://fsharp.org

open Expecto

[<Tests>]
let tests = 
    testList "Test Group" [
        test "A simple test" {
            let subject = "Hello World"
            Expect.equal subject "Hello World" "The strings should be equal"
        }
        testCase "A simple test2" <| fun _ -> 
            let subject = "Hello World2"
            Expect.equal subject "Hello World2" "The strings should be equal"
    ]

[<EntryPoint>]
let main argv =
    Tests.runTestsInAssembly defaultConfig argv
