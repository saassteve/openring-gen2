import Foundation
import Testing
@testable import Runner

struct RunnerTests {
    @Test func bluetoothPermissionHasUsageDescription() {
        let bundle = Bundle(for: AppDelegate.self)
        let reason = bundle.object(forInfoDictionaryKey: "NSBluetoothAlwaysUsageDescription") as? String
        #expect(reason?.isEmpty == false)
    }
}
