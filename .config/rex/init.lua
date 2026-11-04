-- Session
rex.bind("shift+cmd+r", "session.refresh")

-- Tabs
rex.bind("cmd+alt+left", "client.tab.previous")
rex.bind("cmd+alt+right", "client.tab.next")
rex.bind("ctrl+cmd+left", "client.tab.move", { direction = "backward" })
rex.bind("ctrl+cmd+right", "client.tab.move", { direction = "forward" })

-- Panes
rex.bind("ctrl+alt+left",  "pane.focus.left")
rex.bind("ctrl+alt+right", "pane.focus.right")

-- Resize
rex.mode("resize", { exclusive = true })
rex.bind("cmd+r", "client.mode.enter", { name = "resize" })
for _, d in ipairs({ "left", "right", "up", "down" }) do
  rex.bind("resize/" .. d, "pane.resize", { direction = d, amount = 1 })
  rex.bind("resize/shift+" .. d, "pane.resize", { direction = d, amount = 5 })
end
rex.bind("resize/=", "pane.balance")
rex.bind("resize/enter", "client.mode.exit")
rex.bind("cmd+ctrl+alt+r", "client.visibility.toggle")
