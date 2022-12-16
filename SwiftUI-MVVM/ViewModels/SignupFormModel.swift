//
//  SignupFormModel.swift
//  SwiftUI-MVVM
//
//  Created by Rome on 11/15/22.
//  Copyright © 2022 Yusuke Kita. All rights reserved.
//

import Foundation
import Combine

class SignupFormModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    
    @Published var formIsValid = false
    
    private var publishers = Set<AnyCancellable>()
    
    init() {
        isSignupFormValidPublisher
            .receive(on: RunLoop.main)
            .assign(to: \.formIsValid, on: self)
            .store(in: &publishers)
    }
}

private extension SignupFormModel {
    var isUserEmailValidPublisher: AnyPublisher<Bool, Never> {
        $email
            .map { email in
                let emailPredicate = NSPredicate(format:"SELF MATCHES %@", "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}")
                return emailPredicate.evaluate(with: email)
            }
            .eraseToAnyPublisher()
    }
    
    var isPasswordValidPublisher: AnyPublisher<Bool, Never> {
        $password
            .map{ password in
                return password.count >= 8
            }
            .eraseToAnyPublisher()
    }
    
    var isSignupFormValidPublisher: AnyPublisher<Bool, Never> {
        Publishers.CombineLatest(
            isUserEmailValidPublisher,
            isPasswordValidPublisher
        )
        .map { isValidEmail, isValidPassword in
            return isValidEmail && isValidPassword
        }
        .eraseToAnyPublisher()
    }
}