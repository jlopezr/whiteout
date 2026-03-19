import Cocoa
import QuartzCore

final class ExitView: NSView {
    private let lineLayer = CALayer()
    private let lineWidth: CGFloat = 4.0
    private let slideDuration: CFTimeInterval = 8.0

    override var acceptsFirstResponder: Bool { true }

    override func viewDidMoveToWindow() {
        window?.makeFirstResponder(self)
        wantsLayer = true
        setupLineLayer()
    }

    private func setupLineLayer() {
        guard let layer = self.layer else { return }

        lineLayer.backgroundColor = NSColor(calibratedWhite: 0.15, alpha: 1.0).cgColor
        lineLayer.frame = CGRect(x: -lineWidth, y: 0, width: lineWidth, height: bounds.height)
        layer.addSublayer(lineLayer)
        startSlideAnimation()
    }

    private func startSlideAnimation() {
        // Position animation from just left of the view to just right
        let fromX = -lineWidth / 2.0
        let toX = bounds.width + lineWidth / 2.0

        let anim = CABasicAnimation(keyPath: "position.x")
        anim.fromValue = fromX
        anim.toValue = toX
        anim.duration = slideDuration
        anim.repeatCount = .infinity
        anim.timingFunction = CAMediaTimingFunction(name: .linear)

        // Ensure the model layer is positioned at the start so the animation repeats predictably
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        lineLayer.position.x = fromX
        CATransaction.commit()

        lineLayer.add(anim, forKey: "slide")
    }

    override func layout() {
        super.layout()
        // Update height and restart animation so it adapts to screen size changes
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        lineLayer.frame.size.height = bounds.height
        lineLayer.removeAnimation(forKey: "slide")
        lineLayer.position.x = -lineWidth / 2.0
        CATransaction.commit()
        startSlideAnimation()
    }

    override func keyDown(with event: NSEvent) {
        NSApp.terminate(nil)
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    var windows: [NSWindow] = []

    func applicationDidFinishLaunching(_ notification: Notification) {
        for screen in NSScreen.screens {
            let window = NSWindow(
                contentRect: screen.frame,
                styleMask: .borderless,
                backing: .buffered,
                defer: false,
                screen: screen
            )

            window.backgroundColor = .white
            // Use normal level so it behaves like a regular window (not a screen-saver/fullscreen)
            window.level = .normal
            window.isOpaque = true
            window.hasShadow = false
            // Allow on all spaces but avoid fullscreen auxiliary behavior
            window.collectionBehavior = [.canJoinAllSpaces]

            let view = ExitView(frame: screen.frame)
            view.wantsLayer = true
            view.layer?.backgroundColor = NSColor.white.cgColor
            window.contentView = view

            window.makeKeyAndOrderFront(nil)
            // Ensure our view becomes first responder after the window is key
            window.makeFirstResponder(view)
            windows.append(window)
        }

        NSApp.activate(ignoringOtherApps: true)
    }
}

let app = NSApplication.shared
let delegate = AppDelegate()
app.setActivationPolicy(.regular)
app.delegate = delegate
app.run()
