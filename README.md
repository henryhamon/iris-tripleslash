 [![Gitter](https://img.shields.io/badge/Available%20on-Intersystems%20Open%20Exchange-00b2a9.svg)](https://openexchange.intersystems.com/package/iris-tripleslash)
 [![Quality Gate Status](https://community.objectscriptquality.com/api/project_badges/measure?project=intersystems_iris_community%2Firis-tripleslash&metric=alert_status)](https://community.objectscriptquality.com/dashboard?id=intersystems_iris_community%2Firis-tripleslash)
 [![Reliability Rating](https://community.objectscriptquality.com/api/project_badges/measure?project=intersystems_iris_community%2Firis-tripleslash&metric=reliability_rating)](https://community.objectscriptquality.com/dashboard?id=intersystems_iris_community%2Firis-tripleslash)

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg?style=flat&logo=AdGuard)](LICENSE)

# iris-tripleSlash

![3slash logo](./assert/3slash.png)

/// (Triple Slash)
Generate unit test cases from the documentation.

## Description

 /// TripleSlash allow us to generate tests from code examples found in method descriptions.

 Inspired in [elixir](https://elixir-lang.org/getting-started/mix-otp/docs-tests-and-with.html) style and in [this idea](https://ideas.intersystems.com/ideas/DP-I-175) from InterSystems Ideas!

## Usage

In order to show you how use TripleSlash to create your unit tests, let use a simple example.

Let's say you have the following class and method which you'd like to write a unit test:

```objectScript
Class dc.sample.ObjectScript
{

ClassMethod TheAnswerForEverything() As %Integer
{
    Set a = 42 
    Write "Hello World!",!
    Write "This is InterSystems IRIS with version ",$zv,!
    Write "Current time is: "_$zdt($h,2)
    Return a
}

}
```

As you can see, the `TheAnswerForEverything()` method just retruns the number `42`. So, let mark in the method documentation how TripleSlash should create a unit test for this method:

```objectScript
/// A simple method for testing purpose.
/// 
/// <example>
/// Write ##class(dc.sample.ObjectScript).Test()
/// 42
/// </example>
ClassMethod TheAnswerForEverything() As %Integer
{
    ...
}
```

Unit tests must be enclosed by tag `<example></example>`. You can add any kind of documentation, but all tests show be within such a tag. Currently, the following assertions are available: `$$$AssertStatusOK`, `$$$AssertStatusNotOK` and `$$$AssertEquals`.

Now, start an IRIS terminal session, go to `IRISAPP`namespace, create an instance of the `Core` class passing the class name (`dc.sample.ObjectScript`) and then run the `Execute()` method:

```
USER>ZN "IRISAPP"
IRISAPP>Do ##class(iris.tripleSlash.Core).%New("dc.sample").Execute()
```

TripleSlash will interpret this like "Given the result of the `Test()` method, asserts that it is equals to `42`". So, a new class will be create within the unit test:

```objectScript
Class iris.tripleSlash.tst.ObjectScript Extends %UnitTest.TestCase
{

Method TestTheAnswerForEverything()
{
  Do $$$AssertEquals(##class(dc.sample.ObjectScript).TheAnswerForEverything(), 42)
}

}
```

Now let's add a new method  for testing other ways to tell to TripleSlash on how to write your unit tests.

```objectScript
Class dc.sample.ObjectScript
{

ClassMethod GuessTheNumber(pNumber As %Integer) As %Status
{
    Set st = $$$OK
    Set theAnswerForEveryThing = 42
    Try {
        Throw:(pNumber '= theAnswerForEveryThing) ##class(%Exception.StatusException).%New("Sorry, wrong number...")
    } Catch(e) {
        Set st = e.AsStatus()
    }
    Return st
}

}
```

As you can see, the `GuessTheNumber()` method expect a number, returns `$$$OK` just when the number `42` is passed or an error for any other value. So, let mark in the method documentation that how TripleSlash should create a unit test for this method:

```objectScript
/// Another simple method for testing purpose.
/// 
/// <example>
/// Do ##class(dc.sample.ObjectScript).GuessTheNumber(42)
/// $$$OK
/// Do ##class(dc.sample.ObjectScript).GuessTheNumber(23)
/// $$$NotOK
/// </example>
ClassMethod GuessTheNumber(pNumber As %Integer) As %Status
{
    ...
}
```

Run again the `Execute()` method and you'll see a new test method in unit test class `iris.tripleSlash.tst.ObjectScript`:

```objectScript
Class iris.tripleSlash.tst.ObjectScript Extends %UnitTest.TestCase
{

Method TestGuessTheNumber()
{
  Do $$$AssertStatusOK(##class(dc.sample.ObjectScript).GuessTheNumber(42))
  Do $$$AssertStatusNotOK(##class(dc.sample.ObjectScript).GuessTheNumber(23))
}

}
```

# ZPM installation

If you would to use TripleSlash into your IRIS instance and start to get your unit tests in a less boilerplate way, just run this command in a IRIS terminal:

```
zpm "install iris-tripleSlash"
```

## Docker installation 

If you would like to test TriplSlash in a new IRIS instance running on a container, follow this steps:

1) Clone/git pull the repo into any local directory

```
$ git clone https://github.com/henryhamon/iris-tripleslash.git
```

2) Open the terminal in this directory and call the command to build and run InterSystems IRIS in container:

```
$ docker-compose up -d
```

3) Open a VS Code instance in the directory:

```
cd ./iris-tripleslash
code .
```

Install [VSCode](https://code.visualstudio.com/), [Docker](https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-docker) and the [InterSystems ObjectScript Extension Pack](https://marketplace.visualstudio.com/items?itemName=intersystems-community.objectscript-pack) plugin and open the folder in VSCode.

If everything goes like expected, you're ready to test tripleSpash!
