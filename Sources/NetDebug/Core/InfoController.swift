import Foundation

class InfoController: GenericController {

  func generateInfoString(_ ipAddress: String) -> NSAttributedString {
    var tempString: String
    tempString = String()

    tempString += "[App name] \n\(DebugInfo.getAppName())\n\n"

    tempString +=
      "[App version] \n\(DebugInfo.getAppVersionNumber()) (build \(DebugInfo.getAppBuildNumber()))\n\n"

    tempString += "[App bundle identifier] \n\(DebugInfo.getBundleIdentifier())\n\n"

    tempString += "[Device OS] \niOS \(DebugInfo.getOSVersion())\n\n"

    tempString += "[Device type] \n\(DebugInfo.getDeviceType())\n\n"

    tempString += "[Device screen resolution] \n\(DebugInfo.getDeviceScreenResolution())\n\n"

    tempString += "[Device IP address] \n\(ipAddress)\n\n"

    return formatString(tempString)
  }
}
