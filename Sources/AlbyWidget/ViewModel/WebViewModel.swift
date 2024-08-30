import Foundation
import Combine

class WebViewModel: ObservableObject {
    // iOS to Javascript
    var callbackValueFromNative = PassthroughSubject<String, Never>()

    // Javascript to IOS
    var callbackValueJS = PassthroughSubject<String, Never>()
}
