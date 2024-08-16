//
//  User.swift
//  BoulderBro
//
//  Created by Hazz on 16/08/2024.
//

import Foundation

struct User: Identifiable, Codable {
    let id: String
    let fullname: String
    let email: String
    
    var initals: String {
        let formatter = PersonNameComponentsFormatter()
        if let components = formatter.personNameComponents(from: fullname){
            formatter.style = .abbreviated
            return formatter.string(from: components)
    }
        
    return ""
}
    var firstName: String {
            let formatter = PersonNameComponentsFormatter()
            if let components = formatter.personNameComponents(from: fullname),
               let givenName = components.givenName {
                return givenName
            }
            return "" // Or handle the case where first name can't be extracted
        }

        var lastName: String {
            let formatter = PersonNameComponentsFormatter()
            if let components = formatter.personNameComponents(from: fullname),
               let familyName = components.familyName {
                return familyName
            }
            return "" // Or handle the case where last name can't be extracted
        }
    }
