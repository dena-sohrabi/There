import Foundation
import ServiceManagement

func installLaunchAgent() {
    let fileManager = FileManager.default

    guard let libraryDirectory = fileManager.urls(for: .libraryDirectory, in: .userDomainMask).first else {
        print("Unable to find user's Library directory")
        return
    }

    let launchAgentsDirectory = libraryDirectory.appendingPathComponent("LaunchAgents")
    let plistName = "pm.there.There.LaunchAgent.plist"
    let plistPath = launchAgentsDirectory.appendingPathComponent(plistName)

    // Create LaunchAgents directory if it doesn't exist
    if !fileManager.fileExists(atPath: launchAgentsDirectory.path) {
        do {
            try fileManager.createDirectory(at: launchAgentsDirectory, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print("Error creating LaunchAgents directory: \(error)")
            return
        }
    }

    // Create the plist content
    let plistContent = """
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
        <key>Label</key>
        <string>pm.there.There.LaunchAgent</string>
        <key>ProgramArguments</key>
        <array>
            <string>/Applications/There.app/Contents/MacOS/There</string>
        </array>
        <key>RunAtLoad</key>
        <true/>
        <key>KeepAlive</key>
        <true/>
        <key>LimitLoadToSessionType</key>
        <string>Aqua</string>
    </dict>
    </plist>
    """

    do {
        // Write the plist content to the file
        try plistContent.write(to: plistPath, atomically: true, encoding: .utf8)
        print("Launch Agent plist created successfully")

        // Set the correct permissions
        try fileManager.setAttributes([.posixPermissions: 0o644], ofItemAtPath: plistPath.path)

        // Load the launch agent
        try Process.run(URL(fileURLWithPath: "/bin/launchctl"), arguments: ["load", plistPath.path])
        print("Launch Agent loaded successfully")
    } catch {
        print("Error installing or loading Launch Agent: \(error)")
    }

    // For macOS 13 and later, also register using SMAppService
    if #available(macOS 13.0, *) {
        do {
            try SMAppService.mainApp.register()
            print("App registered as login item using SMAppService")
        } catch {
            print("Failed to register app as login item using SMAppService: \(error)")
        }
    }
}

func uninstallLaunchAgent() {
    let fileManager = FileManager.default
    guard let libraryDirectory = fileManager.urls(for: .libraryDirectory, in: .userDomainMask).first else {
        print("Unable to find user's Library directory")
        return
    }

    let launchAgentsDirectory = libraryDirectory.appendingPathComponent("LaunchAgents")
    let plistName = "pm.there.There.LaunchAgent.plist"
    let plistPath = launchAgentsDirectory.appendingPathComponent(plistName)

    do {
        // Unload the launch agent
        try Process.run(URL(fileURLWithPath: "/bin/launchctl"), arguments: ["unload", plistPath.path])
        print("Launch Agent unloaded successfully")

        // Remove the plist file
        try fileManager.removeItem(at: plistPath)
        print("Launch Agent plist removed successfully")
    } catch {
        print("Error uninstalling Launch Agent: \(error)")
    }

    // For macOS 13 and later, also unregister using SMAppService
    if #available(macOS 13.0, *) {
        do {
            try SMAppService.mainApp.unregister()
            print("App unregistered as login item using SMAppService")
        } catch {
            print("Failed to unregister app as login item using SMAppService: \(error)")
        }
    }
}
