; AutoHotkey v2 — mouse remap for Windows Terminal + Neovim
; winget install AutoHotkey.AutoHotkey

#HotIf WinActive("ahk_exe WindowsTerminal.exe")

XButton1::Send "^o"          ; 侧键后退 → C-o (jump back)
XButton2::Send "^i"          ; 侧键前进 → C-i (jump forward)
MButton::Send ":q{Enter}"    ; 中键 → :q 退出

#HotIf
