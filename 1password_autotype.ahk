#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

; --------------- Paste password only -------------------------------
^p:: ; Ctrl + p
^+v:: ; Ctrl + Shift + v
StartPastePassword()

; --------------- Paste username and password only ------------------
^ü:: ; Ctrl + ü
StartPasteUserName()

; --------------- Functions -----------------------------------------
StartPastePassword()
{
    1password_window_pid := GetCurrentWindowPID()
    target_window_pid := GetWindowToPasteIn()
    initialize(target_window_pid, 1password_window_pid)
    PastePassword(1password_window_pid, target_window_pid)
    return
}

StartPasteUserName()
{
    1password_window_pid := GetCurrentWindowPID()
    target_window_pid := GetWindowToPasteIn()
    initialize(target_window_pid, 1password_window_pid)
    WinGetTitle, target_title, ahk_pid %target_window_pid%
    ;MsgBox, Pasting to pid=%target_window_pid% with title=%target_title%
    if target_window_pid is space
    {
        MsgBox, Target window not found
        Exit
    }
    PasteUserName(1password_window_pid, target_window_pid)
    Send {Tab}
    Sleep 100
    WinActivate, ahk_pid %1password_window_pid%
    ;Sleep 500
    ;PastePassword(1password_window_pid, target_window_pid)
    return
}

initialize(target_window_pid, 1password_window_pid)
{
    QuitIfNotCalledFrom1Password(1password_window_pid)
    if target_window_pid is space
        Exit
}

QuitIfNotCalledFrom1Password(1password_window_pid)
{
    if WindowIs1Password(1password_window_pid) = false
        Exit
}

WindowIs1Password(window_pid)
{
    WinGetTitle, current_title, ahk_pid %window_pid%
    if current_title contains 1Password
    {
        return true
    } else {
        return false
    }
}

GetCurrentWindowPID()
{
    WinGet, current_window_pid, PID, A
    return current_window_pid
}

PasteUserName(1password_window_pid, target_window_pid)
{
    WinActivate, ahk_pid %1password_window_pid%
    Sleep 200
    Send ^c ; Ctrl + c to copy username
    Sleep 200 ; Wait for pop-up to disappear and re-focus previous window
    WinActivate, ahk_pid %target_window_pid%
    Sleep 300 ; Wait for pop-up to disappear and re-focus previous window
    SetKeyDelay, 20
    SendRaw, %Clipboard% ; Paste pw to focused field
    clipboard := "" ; Empty clipboard
}

PastePassword(1password_window_pid, target_window_pid)
{
    WinActivate, ahk_pid %1password_window_pid%
    Sleep 200
    Send ^+c ; Ctrl + Shift + c to copy password
    Sleep 200 ; Wait for pop-up to disappear and re-focus previous window
    WinActivate, ahk_pid %target_window_pid%
    Sleep 300 ; Wait for pop-up to disappear and re-focus previous window
    SetKeyDelay, 20
    SendRaw, %Clipboard% ; Paste pw to focused field
    clipboard := "" ; Empty clipboard
}

GetWindowToPasteIn()
{
    list := ""
    WinGet, id, list
    Loop, %id%
    {
        this_id := id%A_Index%
        ;WinGet, target_pid, PID, ahk_id %this_id%
        WinGetTitle, title, ahk_id %this_id%

        FoundPos := InStr(title, "1Password")
        ;MsgBox, 1Password found at pos=%FoundPos%
        if (FoundPos = 0) and (title != "")
        {
            WinGet, this_pid, PID, ahk_id %this_id%
            ;MsgBox, Success for title=%title% id=%this_id% pid=%this_pid%
            ;MsgBox, Returning pid=%this_pid%
            return this_pid
        }
    }
}