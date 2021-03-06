//
//  Mappable+BasicType.swift
//  Mappable
//
//  Created by Leavez on 6/1/18.
//

import Foundation

// MARK: - Integer

extension Int: Mappable {}
extension Int8: Mappable {}
extension Int16: Mappable {}
extension Int32: Mappable {}
extension Int64: Mappable {}
extension UInt: Mappable {}
extension UInt8: Mappable {}
extension UInt16: Mappable {}
extension UInt32: Mappable {}
extension UInt64: Mappable {}

extension Mappable where Self: FixedWidthInteger {

    public init(map: Mapper) throws {

        switch map.rootValue() {
        case let v as Self:
            self = v
        case let v as NSNumber:
            let value = v.int64Value
            if value <= Self.max && value >= Self.min {
                self = Self(value)
            } else {
                throw ErrorType.cannotCast(v, "\(Self.self)")
            }
        case let v as String:
            if let v = Self(v) {
                self = v
            } else {
                throw ErrorType.cannotCast(v, "\(Self.self)")
            }
        default:
            throw ErrorType.cannotCast(map.rootValue(), "\(Self.self)")
        }
    }

}


// MARK: - Float

extension Double: Mappable {

    public init(map: Mapper) throws {
        switch map.rootValue() {
        case let v as Double:
            self = v
        case let v as NSNumber:
            self = v.doubleValue
        case let v as String:
            if let v = Double(v) {
                self = v
            } else {
                throw ErrorType.cannotCast(v, "\(Double.self)")
            }
        default:
            throw ErrorType.cannotCast(map.rootValue(), "\(Double.self)")
        }
    }
}

extension Float: Mappable {

    public init(map: Mapper) throws {
        switch map.rootValue() {
        // Swift 4.1 breaks Float casting from `NSNumber`,
        // so we skip cast directly to Float
        case let v as NSNumber:
            self = v.floatValue
        case let v as String:
            if let v = Double(v) {
                self = Float(v)
            } else {
                throw ErrorType.cannotCast(v, "\(Float.self)")
            }
        default:
            throw ErrorType.cannotCast(map.rootValue(), "\(Float.self)")
        }
    }
}

#if canImport(CoreGraphics)
import CoreGraphics
extension CGFloat: Mappable {

    public init(map: Mapper) throws {
        switch map.rootValue() {
        case let v as CGFloat:
            self = v
        case let v as NSNumber:
            self = CGFloat(v.doubleValue)
        case let v as String:
            if let v = Double(v) {
                self = CGFloat(v)
            } else {
                throw ErrorType.cannotCast(v, "\(CGFloat.self)")
            }
        default:
            throw ErrorType.cannotCast(map.rootValue(), "\(CGFloat.self)")
        }
    }
}
#endif

// MARK: - Bool

extension Bool: Mappable {

    public init(map: Mapper) throws {
        switch map.rootValue() {
        case let v as Bool:
            self = v
        case let v as Int:
            self = v != 0
        case let v as String:
            switch v {
            case "false", "False", "FALSE", "NO":
                self = false
            case "true", "True", "TRUE", "YES":
                self = true
            default:
                throw ErrorType.cannotCast(v, "\(Bool.self)")
            }
        default:
            throw ErrorType.cannotCast(map.rootValue(), "\(Bool.self)")
        }
    }
}


// MARK: - String && URL && Date

extension String: Mappable {

    public init(map: Mapper) throws {
        switch map.rootValue() {
        case let v as String:
            self = v
        case let v as Int:
            self = String(format: "%ld", v)
        case let v as NSNumber:
            self = String(format: "%@", v)
        case let v as Date:
            self = iso8601DateFormatter.string(from: v)
        default:
            throw ErrorType.cannotCast(map.rootValue(), "\(String.self)")
        }
    }
}

extension URL: Mappable {

    public init(map: Mapper) throws {
        if let v = map.rootValue() as? String,
            let url = URL(string: v) {
            self = url
        } else {
            throw ErrorType.cannotCast(map.rootValue(), "\(URL.self)")
        }
    }
}

extension Date: Mappable {

    public init(map: Mapper) throws {
        if let v = map.rootValue() as? String,
            let date = iso8601DateFormatter.date(from: v) {
            self = date
        } else {
            throw ErrorType.cannotCast(map.rootValue(), "\(Date.self)")
        }
    }
}

private let iso8601DateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
    return formatter
}()
