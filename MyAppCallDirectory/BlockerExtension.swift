import Foundation
import CallKit

class CallDirectoryHandler: CXCallDirectoryProvider {

    override func beginRequest(with context: CXCallDirectoryExtensionContext) {
        

        if let blockedNumbers = getBlockedNumbers() {
            for number in blockedNumbers {
                context.addBlockingEntry(withNextSequentialPhoneNumber: number)
            }
        }

        context.completeRequest()
    }

    func getBlockedNumbers() -> [Int64]? {
        let sharedDefaults = UserDefaults(suiteName: "T.ScamShield.MyAppCallDirectory")
        return sharedDefaults?.array(forKey: "BlockedNumbers") as? [Int64]
    }
}
