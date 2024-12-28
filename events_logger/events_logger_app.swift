import Cocoa
import Accessibility
import Darwin

struct FocusedWindow : Equatable {
    var appName: String
    var windowTitle: String
    var bundleIdentifier: String
}

class EventsLoggerAppDelegate : NSObject, NSApplicationDelegate {

    var lastFocusedWindow: FocusedWindow = FocusedWindow(appName: "", windowTitle: "", bundleIdentifier: "")
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        handle()
        NSWorkspace.shared.notificationCenter.addObserver(self,
            selector: #selector(activatedApp),
            name: NSWorkspace.didActivateApplicationNotification,
            object: nil)
    }

    @objc dynamic func activatedApp(_ notification: Notification) {
        handle()
    }

    func handle() -> Void {
        let pid = NSWorkspace.shared.frontmostApplication!.processIdentifier
        let appRef = AXUIElementCreateApplication(pid)
        var value: AnyObject?
        AXUIElementCopyAttributeValue(appRef, kAXWindowsAttribute as CFString, &value)
        // the first window of the front most application is the front most window
        if let targetWindow = (value as? [AXUIElement])?.first {
            var title: AnyObject?
            AXUIElementCopyAttributeValue(targetWindow, kAXTitleAttribute as CFString, &title)
            if let windowTitle = title as? String {
                let currentWindow = FocusedWindow(appName: NSWorkspace.shared.frontmostApplication?.localizedName ?? "", windowTitle: windowTitle, bundleIdentifier: NSWorkspace.shared.frontmostApplication?.bundleIdentifier ?? "")
                if currentWindow != lastFocusedWindow {
                    lastFocusedWindow = currentWindow
                    print(lastFocusedWindow)
                }
            }
        }
    }

    func applicationWillTerminate(_ notification: Notification) {
        // Clean up observers
        NotificationCenter.default.removeObserver(self)
    }
}

func main() {
    setbuf(stdout, nil)
    let delegate = EventsLoggerAppDelegate()
    NSApplication.shared.delegate = delegate
    NSApplication.shared.run()
}

main()
