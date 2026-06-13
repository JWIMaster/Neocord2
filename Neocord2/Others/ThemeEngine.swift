//
//  ThemeEngine.swift
//  Neocord
//
//  Created by JWI on 6/11/2025.
//

import UIKit
import UIKitCompatKit
import UIKitExtensions

public final class ThemeEngine {
    public static var enableGlass: Bool {
        get {
            switch device {
            case .a4: return false
            default:
                if UserDefaults.standard.object(forKey: "enableGlass") == nil { return true }
                return UserDefaults.standard.bool(forKey: "enableGlass")
            }
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "enableGlass")
            UserDefaults.standard.synchronize()
        }
    }
    
    public static var isHighPowerDevice: Bool {
        if device != .a4, device != .a5, device != .a6, device != .a7_a8 {
            return true
        } else {
            return false
        }
    }
    
    public static var chosenTheme: ThemeOptions {
        get {
            switch device {
            case .a4: return .fallback
            default:
                guard let stored = UserDefaults.standard.string(forKey: "chosenTheme") else {
                    return .glass
                }
                return ThemeOptions(rawValue: stored) ?? .glass
            }
        }
        set {
            let valueString = newValue.rawValue
            UserDefaults.standard.set(valueString, forKey: "chosenTheme")
            UserDefaults.standard.synchronize()
        }
    }


    public static var enableAnimations: Bool {
        get {
            switch device {
            case .a4, .a5, .a6: return false
            case .a7_a8:
                if #available(iOS 9.0, *) {
                    if UserDefaults.standard.object(forKey: "enableAnimations") == nil { return true }
                    return UserDefaults.standard.bool(forKey: "enableAnimations")
                } else { return false }
            default:
                if UserDefaults.standard.object(forKey: "enableAnimations") == nil { return true }
                return UserDefaults.standard.bool(forKey: "enableAnimations")
            }
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "enableAnimations")
            UserDefaults.standard.synchronize()
        }
    }
    public static var enableProfileTinting: Bool {
        get {
            if UserDefaults.standard.object(forKey: "enableProfileTinting") == nil { return true }
            return UserDefaults.standard.bool(forKey: "enableProfileTinting")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "enableProfileTinting")
            UserDefaults.standard.synchronize()
        }
    }
    
    init() {
        
    }
    
    public enum ThemeOptions: String {
        case glass, fallback, native
    }
}
