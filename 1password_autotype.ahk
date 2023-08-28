#Requires AutoHotkey v2.0
#SingleInstance Force

; --------------- Paste password only -------------------------------
^ü:: ; Ctrl + ü
{
    Onepassword_window_pid := GetCurrentWindowPID()
    target_window_pid := GetWindowToPasteIn()
    initialize(target_window_pid, Onepassword_window_pid)
    PastePassword(Onepassword_window_pid, target_window_pid)
    return
}

; --------------- Onetime password only -------------------------------
^+ü:: ; Ctrl + ü
{
    Onepassword_window_pid := GetCurrentWindowPID()
    target_window_pid := GetWindowToPasteIn()
    initialize(target_window_pid, Onepassword_window_pid)
    PasteOneTimePassword(Onepassword_window_pid, target_window_pid)
    return
}

; --------------- Paste username only ------------------
^p:: ; Ctrl + p
{
    Onepassword_window_pid := GetCurrentWindowPID()
    target_window_pid := GetWindowToPasteIn()
    initialize(target_window_pid, Onepassword_window_pid)
    target_title := WinGetTitle("ahk_pid " target_window_pid)
    ;MsgBox, Pasting to pid=%target_window_pid% with title=%target_title%
    if target_window_pid = ""
    {
        MsgBox("Target window not found")
        Exit
    }
    PasteUserName(Onepassword_window_pid, target_window_pid)
    Send "{Tab}"
    Sleep 100
    WinActivate("ahk_pid " Onepassword_window_pid)
    ;Sleep 500
    ;PastePassword(1password_window_pid, target_window_pid)
    return
}

; --------------- Functions -----------------------------------------
initialize(target_window_pid, Onepassword_window_pid)
{
    QuitIfNotCalledFrom1Password(Onepassword_window_pid)
    if target_window_pid = ""
        Exit
}

QuitIfNotCalledFrom1Password(Onepassword_window_pid)
{
    if WindowIs1Password(Onepassword_window_pid) = false
        Exit
}

WindowIs1Password(window_pid)
{
    current_title := WinGetTitle("ahk_pid " window_pid)
    if current_title ~= ".*1Password.*"
    {
        return true
    } else {
        return false
    }
}

GetCurrentWindowPID()
{
    current_window_pid := WinGetPID("A")
    return current_window_pid
}

PasteUserName(Onepassword_window_pid, target_window_pid)
{
    WinActivate("ahk_pid " Onepassword_window_pid)
    Sleep 200
    Send "^c" ; Ctrl + c to copy username
    Sleep 200 ; Wait for pop-up to disappear and re-focus previous window
    WinActivate("ahk_pid " target_window_pid)
    Sleep 300 ; Wait for pop-up to disappear and re-focus previous window
    SetKeyDelay 20
    Send "{Raw}" A_Clipboard ; Paste pw to focused field
    A_Clipboard := "" ; Empty clipboard
}

PastePassword(Onepassword_window_pid, target_window_pid)
{
    WinActivate("ahk_pid " Onepassword_window_pid)
    Sleep 200
    Send "^+c" ; Ctrl + Shift + c to copy password
    Sleep 200 ; Wait for pop-up to disappear and re-focus previous window
    WinActivate("ahk_pid " target_window_pid)
    Sleep 300 ; Wait for pop-up to disappear and re-focus previous window
    SetKeyDelay(20)
    Send "{Raw}" A_Clipboard ; Paste pw to focused field
    A_Clipboard := "" ; Empty clipboard
}

PasteOneTimePassword(Onepassword_window_pid, target_window_pid)
{
    WinActivate("ahk_pid " Onepassword_window_pid)
    Sleep 200
    Send "^!c" ; Ctrl + Shift + c to copy password
    Sleep 200 ; Wait for pop-up to disappear and re-focus previous window
    WinActivate("ahk_pid " target_window_pid)
    Sleep 300 ; Wait for pop-up to disappear and re-focus previous window
    SetKeyDelay(20)
    Send "{Raw}" A_Clipboard ; Paste pw to focused field
    A_Clipboard := "" ; Empty clipboard
}

GetWindowToPasteIn()
{
    list := ""
    list := WinGetList()
    Loop
    {
        this_id := list[A_Index]
        ;WinGet, target_pid, PID, ahk_id %this_id%

        if not WinExist("ahk_id " this_id)
            continue

        title := WinGetTitle("ahk_id " this_id)

        FoundPos := InStr(title, "1Password")
        ;MsgBox, 1Password found at pos=%FoundPos%
        if (FoundPos = 0) and (title != "")
        {
            this_pid := WinGetPID("ahk_id" this_id)
            ;MsgBox, Success for title=%title% id=%this_id% pid=%this_pid%
            ;MsgBox, Returning pid=%this_pid%
            return this_pid
        }
    }
}