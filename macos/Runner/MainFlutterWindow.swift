import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    // 窗口配置
    self.title = "AI NAILS"
    self.titlebarAppearsTransparent = true
    self.isMovableByWindowBackground = true
    
    // 最小窗口尺寸
    self.minSize = NSSize(width: 900, height: 600)
    self.setFrame(NSRect(x: 0, y: 0, width: 1280, height: 800), display: true)
    self.center()
    
    // 窗口层级和样式
    self.level = .normal
    self.collectionBehavior = [.fullScreenPrimary, .managed]
    
    // 标题栏样式
    self.titleVisibility = .visible
    self.styleMask.insert(.fullSizeContentView)
    self.styleMask.insert(.resizable)
    
    // 背景色（与 Flutter 主题保持一致）
    self.backgroundColor = NSColor(red: 0.039, green: 0.039, blue: 0.059, alpha: 1.0)
    
    // 窗口代理设置
    self.delegate = self as? NSWindowDelegate

    RegisterGeneratedPlugins(registry: flutterViewController)

    super.awakeFromNib()
  }
}
