import Cocoa
import QuartzCore

final class WhiteWindow: NSWindow {
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { true }
}

final class OverlayView: NSView {
    private let lineLayer = CALayer()
    private let lineWidth: CGFloat = 4.0
    private let slideDuration: CFTimeInterval = 8.0

    private enum DisplayMode: CaseIterable {
        case white
        case greyBlack
        case blackWhite

        var backgroundColor: NSColor {
            switch self {
            case .white:
                return .white
            case .greyBlack:
                return NSColor(calibratedWhite: 0.6, alpha: 1.0)
            case .blackWhite:
                return .black
            }
        }

        var lineColor: NSColor {
            switch self {
            case .white:
                return NSColor(calibratedWhite: 0.15, alpha: 1.0)
            case .greyBlack:
                return .black
            case .blackWhite:
                return .white
            }
        }
    }

    private var mode: DisplayMode = .white

    override var acceptsFirstResponder: Bool { true }

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        wantsLayer = true
        setupLineLayer()
        applyCurrentMode()
        window?.makeFirstResponder(self)
    }

    private func setupLineLayer() {
        guard let layer = self.layer else { return }

        lineLayer.frame = CGRect(x: -lineWidth, y: 0, width: lineWidth, height: bounds.height)
        if lineLayer.superlayer == nil {
            layer.addSublayer(lineLayer)
        }
        startSlideAnimation()
    }

    private func applyCurrentMode() {
        layer?.backgroundColor = mode.backgroundColor.cgColor
        lineLayer.backgroundColor = mode.lineColor.cgColor
    }

    private func cycleMode() {
        switch mode {
        case .white:
            mode = .greyBlack
        case .greyBlack:
            mode = .blackWhite
        case .blackWhite:
            mode = .white
        }
        applyCurrentMode()
    }

    private func startSlideAnimation() {
        let fromX = -lineWidth / 2.0
        let toX = bounds.width + lineWidth / 2.0

        let anim = CABasicAnimation(keyPath: "position.x")
        anim.fromValue = fromX
        anim.toValue = toX
        anim.duration = slideDuration
        anim.repeatCount = .infinity
        anim.timingFunction = CAMediaTimingFunction(name: .linear)

        CATransaction.begin()
        CATransaction.setDisableActions(true)
        lineLayer.position = CGPoint(x: fromX, y: bounds.height / 2.0)
        CATransaction.commit()

        lineLayer.add(anim, forKey: "slide")
    }

    override func layout() {
        super.layout()

        CATransaction.begin()
        CATransaction.setDisableActions(true)
        lineLayer.bounds = CGRect(x: 0, y: 0, width: lineWidth, height: bounds.height)
        lineLayer.position = CGPoint(x: -lineWidth / 2.0, y: bounds.height / 2.0)
        lineLayer.removeAnimation(forKey: "slide")
        CATransaction.commit()

        startSlideAnimation()
    }

    override func keyDown(with event: NSEvent) {
        if event.keyCode == 53 { // Esc
            NSApp.terminate(nil)
            return
        }

        if event.modifierFlags.intersection(.deviceIndependentFlagsMask).contains(.command),
           event.charactersIgnoringModifiers?.lowercased() == "q" {
            NSApp.terminate(nil)
            return
        }

        if event.keyCode == 49 { // Space
            cycleMode()
            return
        }

        super.keyDown(with: event)
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    var windows: [WhiteWindow] = []
    var keyMonitor: Any?

    func applicationDidFinishLaunching(_ notification: Notification) {
        keyMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            if event.keyCode == 53 {
                NSApp.terminate(nil)
                return nil
            }

            if event.modifierFlags.intersection(.deviceIndependentFlagsMask).contains(.command),
               event.charactersIgnoringModifiers?.lowercased() == "q" {
                NSApp.terminate(nil)
                return nil
            }

            return event
        }

        for screen in NSScreen.screens {
            let window = WhiteWindow(
                contentRect: screen.frame,
                styleMask: .borderless,
                backing: .buffered,
                defer: false,
                screen: screen
            )

            window.backgroundColor = .white
            window.level = .screenSaver
            window.isOpaque = true
            window.hasShadow = false
            window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]

            let view = OverlayView(frame: screen.frame)
            view.wantsLayer = true
            window.contentView = view

            window.makeKeyAndOrderFront(nil)
            window.makeMain()
            window.makeFirstResponder(view)

            windows.append(window)
        }

        NSApp.activate(ignoringOtherApps: true)

        if let first = windows.first,
           let view = first.contentView {
            first.makeKeyAndOrderFront(nil)
            first.makeMain()
            first.makeFirstResponder(view)
        }
    }

    func applicationWillTerminate(_ notification: Notification) {
        if let keyMonitor {
            NSEvent.removeMonitor(keyMonitor)
        }
    }
}

let app = NSApplication.shared
let delegate = AppDelegate()
app.setActivationPolicy(.regular)
app.delegate = delegate
app.run()