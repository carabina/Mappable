# Mappable

[![Swift](https://img.shields.io/badge/swift-4.1-orange.svg?style=flat)](#) [![Swift Package Manager](https://rawgit.com/jlyonsmith/artwork/master/SwiftPackageManager/swiftpackagemanager-compatible.svg)](https://swift.org/package-manager/)

Mappable is a lightweight, easy-to-use framework to convert JSON to model, specially optimized for immutable property initialization. 

```swift
struct Flight: Mappable {
    let number: String
    let time: Date
    
    init(map: Mapper) throws {
        number = try map.from("id")
        time   = try map.from("time")
    }
}
// Flight(JSONString: json)
```

## Features

- JSON to object by just specifying mapping relationships
- Optimized for immutable and optional
- Compatible types conversion : e.g. a Int property could be initialized with String value 
- Nested key path support

## Why Another?

Most JSON to model libraries cannot handle immutable property initialization well. They require to declare properties with `var` and nullable types, which break the sprint of Swift and lead to bad code. Mappable was born for solving this problem.

### compared with others

#### Codable

pros: Codable is native in Swift, need no mapping relationships, and spport 2-direction conversion. (support immutable too) 

cons: Doesn't support inherent class. 

#### HandyJSON

pros: HandyJSON needs no mapping relationships, and support 2-direction conversion (JSON to model, model to JSON).

cons: Doesn't support immutable properies.

#### ObjectMapper

Mappable is highly inspired by ObjectMapper. You could tread Mappable as an improved version of `ImmutableMappable` in ObjectMapper.

pros:  2-direction conversion

cons: Doesn't support immutable very well: 1) cannot handle optional conveniently. 2)  doesn't support of compatible types conversion, which fall the whole object for every small mal-format in JSON. Also missing support for some combinations of types.

#### SwiftyJSON

SwiftyJSON is not a JSON object convertor.  It's only a tool to deal with JSON data in Swift.

## Usage

### support types

- Primitive types: `Int`, `Double`, `String`, `Bool`, `URL`, `Date` ...
- Container types: `Array`, `Dictionary`, `Set`
- Optional type
- Enum, Struct, Object
- Any combination of types above

### the basics

To support mapping, a type should implement `Mappable` protocol, which have only an initializer method:

```swift
class Country: Mappable {
    let name: String
    let cities: [City]   // struct City: Mappable { ... }
    let atContinent: Continent // enum Continent: Mappable { ... }
    
    required init(map: Mapper) throws {
        number      = try map.from("flight_number")
        time        = try map.from("time")
        atContinent = try map.from("location.continent")
    }
}
```

You just need write the mapping relationship: a key path to a property.  Although these lines are just normal assignment statements, types aren't needed to specified, so you could tread these lines as a form to represent mapping relationships. (You could read a line as "try (to) map from XXX".)

Then you could initialize a object like this:

```swift
let c = try Country(JSON: jsonDict)
let d = try? Country(JSONString: jsonString)
```

### optional handling

`Optional` types won't throw an error even if there's no corresponding date in JSON or the date is in mal-format. A `nil` will be assigned in this situation. 

If you declare a property as an optional, it may mean this data isn't strictly required in JSON. So you wish to get a nil value if there's no data actually. 

```swift
struct User: Mappable {
    let ID: String
    let summary: String?
    
    init(map: Mapper) throws {
        ID      = try map.from("id")
        summary = try map.from("summary")
    }
}
let json = ["id": "a123"]
let user = try! User(JSONObject: json) // It won't crash.
```

### custom conversion

The contents in initializer is just plain assignment, so you could do anything to the data. Use `map.rootValue() `  the get the raw JSON value and do what you want.

### compatible types conversion

|                             | Convert from                                                 |
| :-------------------------- | ------------------------------------------------------------ |
| Int, Double, Float, CGFloat | String                                                       |
| Bool                        | Int,  "true", "True", "TRUE", "YES" ,  "false", "False", "FALSE", "NO" |
| String                      | Int, NSNumber, Date( iso8601 )                               |
| URL                         | String                                                       |
| Date                        | String (iso8601)                                             |

More detail at [here](https://github.com/leavez/Mappable/blob/master/Sources/Mappable/Mappable%2BBasicType.swift).

### inheritance

```swift
class InheritantModel: BaseModel {
    let b : Int
    required init(map: Mapper) throws {
        b = try map.from("b")
        try super.init(map: map)
    }
}
```

### nested

Use key path "AAA.BBB" to map a multi-level path value in JSON:

```swift
// let json = """ {"AAA": {"BBB": 1}} """
b = try map.from("AAA.BBB")

// use `n` to get a n-th value in array
// let json = """ {"AAA": [11,22,33]} """
b = try map.from("AAA.`2`") // b = 33
```

## Installation

#### Cocoapods

```ruby
pod 'Mappable'
```

#### Swift Package Manager

```swift
.Package(url: "https://github.com/leavez/Mappable.git", from: "1.0"),
```

## License

Mappable is available under the MIT license. See the LICENSE file for more info.
