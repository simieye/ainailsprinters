import Cocoa
import FlutterMacOS

@NSApplicationMain
class AppDelegate: FlutterAppDelegate {
  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return true
  }
  
  override func applicationDidFinishLaunching(_ notification: Notification) {
    // 设置 Dock 图标和应用名称
    NSApp.setActivationPolicy(.regular)
    NSApp.activate(ignoringOtherApps: true)
    
    // 注册自定义 URL scheme（ainails://）
    let appleEventManager = NSAppleEventManager.shared()
    appleEventManager.setEventHandler(
      self,
      andSelector: #selector(handleGetURLEvent(_:withReplyEvent:)),
      forEventClass: AEEventClass(kInternetEventClass),
      andEventID: AEEventID(kAEGetURL)
    )
    
    super.applicationDidFinishLaunching(notification)
  }
  
  override func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
    // 点击 Dock 图标时恢复窗口
    if !flag {
      for window in sender.windows {
        window.makeKeyAndOrderFront(self)
      }
    }
    return true
  }
  
  @objc func handleGetURLEvent(_ event: NSAppleEventDescriptor, withReplyEvent replyEvent: NSAppleEventDescriptor) {
    guard let urlString = event.paramDescriptor(forKeyword: AEKeyword(keyDirectObject))?.stringValue,
          let url = URL(string: urlString) else { return }
    // 通过 Flutter Method Channel 传递 URL
    if let controller = mainFlutterWindow?.contentViewController as? FlutterViewController {
      let channel = FlutterMethodChannel(
        name: "com.ainails.app/urlscheme",
        binaryMessenger: controller.engine.binaryMessenger
      )
      channel.invokeMethod("handleURL", arguments: url.absoluteString)
    }
  }
  
  override func application(_ application: NSApplication, open urls: [URL]) {
    for url in urls {
      if let controller = mainFlutterWindow?.contentViewController as? FlutterViewController {
        let channel = FlutterMethodChannel(
          name: "com.ainails.app/urlscheme",
          binaryMessenger: controller.engine.binaryMessenger
        )
        channel.invokeMethod("handleURL", arguments: url.absoluteString)
      }
    }
  }
  
  // MARK: - Menu Bar
  override func applicationWillFinishLaunching(_ notification: Notification) {
    let mainMenu = NSMenu()
    
    // App 菜单
    let appMenuItem = NSMenuItem()
    let appMenu = NSMenu()
    appMenu.addItem(NSMenuItem(title: "About AI NAILS", action: #selector(NSApplication.orderFrontStandardAboutPanel(_:)), keyEquivalent: ""))
    appMenu.addItem(NSMenuItem.separator())
    appMenu.addItem(NSMenuItem(title: "Preferences...", action: nil, keyEquivalent: ","))
    appMenu.addItem(NSMenuItem.separator())
    appMenu.addItem(NSMenuItem(title: "Hide AI NAILS", action: #selector(NSApplication.hide(_:)), keyEquivalent: "h"))
    appMenu.addItem(NSMenuItem(title: "Hide Others", action: #selector(NSApplication.hideOtherApplications(_:)), keyEquivalent: "h").withModifierMask([.command, .option]))
    appMenu.addItem(NSMenuItem(title: "Show All", action: #selector(NSApplication.unhideAllApplications(_:)), keyEquivalent: ""))
    appMenu.addItem(NSMenuItem.separator())
    appMenu.addItem(NSMenuItem(title: "Quit AI NAILS", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
    appMenuItem.submenu = appMenu
    mainMenu.addItem(appMenuItem)
    
    // File 菜单
    let fileMenuItem = NSMenuItem()
    let fileMenu = NSMenu(title: "File")
    fileMenu.addItem(NSMenuItem(title: "New Design", action: nil, keyEquivalent: "n"))
    fileMenu.addItem(NSMenuItem(title: "Open...", action: nil, keyEquivalent: "o"))
    fileMenu.addItem(NSMenuItem.separator())
    fileMenu.addItem(NSMenuItem(title: "Import Image...", action: nil, keyEquivalent: "i").withModifierMask([.command, .shift]))
    fileMenu.addItem(NSMenuItem(title: "Export Design...", action: nil, keyEquivalent: "e").withModifierMask([.command, .shift]))
    fileMenu.addItem(NSMenuItem.separator())
    fileMenu.addItem(NSMenuItem(title: "Close Window", action: #selector(NSWindow.performClose(_:)), keyEquivalent: "w"))
    fileMenuItem.submenu = fileMenu
    mainMenu.addItem(fileMenuItem)
    
    // Edit 菜单
    let editMenuItem = NSMenuItem()
    let editMenu = NSMenu(title: "Edit")
    editMenu.addItem(NSMenuItem(title: "Undo", action: #selector(UndoManager.undo), keyEquivalent: "z"))
    editMenu.addItem(NSMenuItem(title: "Redo", action: #selector(UndoManager.redo), keyEquivalent: "Z").withModifierMask([.command, .shift]))
    editMenu.addItem(NSMenuItem.separator())
    editMenu.addItem(NSMenuItem(title: "Cut", action: #selector(NSText.cut(_:)), keyEquivalent: "x"))
    editMenu.addItem(NSMenuItem(title: "Copy", action: #selector(NSText.copy(_:)), keyEquivalent: "c"))
    editMenu.addItem(NSMenuItem(title: "Paste", action: #selector(NSText.paste(_:)), keyEquivalent: "v"))
    editMenu.addItem(NSMenuItem(title: "Select All", action: #selector(NSText.selectAll(_:)), keyEquivalent: "a"))
    editMenuItem.submenu = editMenu
    mainMenu.addItem(editMenuItem)
    
    // View 菜单
    let viewMenuItem = NSMenuItem()
    let viewMenu = NSMenu(title: "View")
    viewMenu.addItem(NSMenuItem(title: "Toggle Full Screen", action: #selector(NSWindow.toggleFullScreen(_:)), keyEquivalent: "f").withModifierMask([.command, .control]))
    viewMenu.addItem(NSMenuItem.separator())
    viewMenu.addItem(NSMenuItem(title: "Zoom In", action: nil, keyEquivalent: "+").withModifierMask([.command]))
    viewMenu.addItem(NSMenuItem(title: "Zoom Out", action: nil, keyEquivalent: "-").withModifierMask([.command]))
    viewMenu.addItem(NSMenuItem(title: "Actual Size", action: nil, keyEquivalent: "0").withModifierMask([.command]))
    viewMenuItem.submenu = viewMenu
    mainMenu.addItem(viewMenuItem)
    
    // Window 菜单
    let windowMenuItem = NSMenuItem()
    let windowMenu = NSMenu(title: "Window")
    windowMenu.addItem(NSMenuItem(title: "Minimize", action: #selector(NSWindow.performMiniaturize(_:)), keyEquivalent: "m"))
    windowMenu.addItem(NSMenuItem(title: "Zoom", action: #selector(NSWindow.performZoom(_:)), keyEquivalent: ""))
    windowMenu.addItem(NSMenuItem.separator())
    windowMenu.addItem(NSMenuItem(title: "Bring All to Front", action: #selector(NSApplication.arrangeInFront(_:)), keyEquivalent: ""))
    windowMenuItem.submenu = windowMenu
    mainMenu.addItem(windowMenuItem)
    
    // Help 菜单
    let helpMenuItem = NSMenuItem()
    let helpMenu = NSMenu(title: "Help")
    helpMenu.addItem(NSMenuItem(title: "AI NAILS Help", action: nil, keyEquivalent: "?").withModifierMask([.command]))
    helpMenu.addItem(NSMenuItem.separator())
    helpMenu.addItem(NSMenuItem(title: "Developer Documentation", action: nil, keyEquivalent: ""))
    helpMenu.addItem(NSMenuItem(title: "Report Issue", action: nil, keyEquivalent: ""))
    helpMenuItem.submenu = helpMenu
    mainMenu.addItem(helpMenuItem)
    
    NSApp.mainMenu = mainMenu
  }
}

// MARK: - NSMenuItem Extension for modifier mask
extension NSMenuItem {
  func withModifierMask(_ mask: NSEvent.ModifierFlags) -> NSMenuItem {
    self.keyEquivalentModifierMask = mask
    return self
  }
}
