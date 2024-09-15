import Foundation

func installLaunchAgent() {
    let fileManager = FileManager.default

    guard let libraryDirectory = fileManager.urls(for: .libraryDirectory, in: .userDomainMask).first else {
        print("Unable to find user's Library directory")
        return
    }

    let launchAgentsDirectory = libraryDirectory.appendingPathComponent("LaunchAgents")
    let plistName = "pm.there.There.LaunchAgent.plist"
    let plistPath = launchAgentsDirectory.appendingPathComponent(plistName)

    if !fileManager.fileExists(atPath: launchAgentsDirectory.path) {
        do {
            try fileManager.createDirectory(at: launchAgentsDirectory, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print("Error creating LaunchAgents directory: \(error)")
            return
        }
    }

    guard let bundlePlistPath = Bundle.main.path(forResource: "pm.there.There.LaunchAgent", ofType: "plist") else {
        print("Unable to find plist in app bundle")
        return
    }

    do {
        if fileManager.fileExists(atPath: plistPath.path) {
            try fileManager.removeItem(at: plistPath)
        }
        try fileManager.copyItem(atPath: bundlePlistPath, toPath: plistPath.path)
        print("Launch Agent installed successfully")
    } catch {
        print("Error installing Launch Agent: \(error)")
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
        try fileManager.removeItem(at: plistPath)
        print("Launch Agent uninstalled successfully")
    } catch {
        print("Error uninstalling Launch Agent: \(error)")
    }
}
