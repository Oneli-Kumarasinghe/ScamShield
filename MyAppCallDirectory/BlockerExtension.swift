import Foundation
import CallKit

class CallDirectoryHandler: CXCallDirectoryProvider {

    override func beginRequest(with context: CXCallDirectoryExtensionContext) {
        context.delegate = self

        if !addAllBlockingPhoneNumbers(to: context) {
            let error = NSError(domain: "CallDirectoryHandler", code: 1, userInfo: nil)
            context.cancelRequest(withError: error)
            return
        }

        context.completeRequest()
    }

    private func addAllBlockingPhoneNumbers(to context: CXCallDirectoryExtensionContext) -> Bool {
        let appGroupID = "group.com.yourcompany.scamshield"
        guard let sharedDefaults = UserDefaults(suiteName: appGroupID),
              let blockedNumbers = sharedDefaults.array(forKey: "BlockedNumbers") as? [Int64] else {
            return false
        }

        for number in blockedNumbers.sorted() {
            context.addBlockingEntry(withNextSequentialPhoneNumber: number)
        }

        return true
    }
}

extension CallDirectoryHandler: CXCallDirectoryExtensionContextDelegate {
    func requestFailed(for extensionContext: CXCallDirectoryExtensionContext, withError error: Error) {
        print("Call Directory Request Failed: \(error.localizedDescription)")
    }
}
