#Requires AutoHotkey v2.0
#SingleInstance Force

; --------------- Paste password only -------------------------------
^ß:: ; Ctrl + ß
^ü:: ; Ctrl + ü
{
    Onepassword_window_pid := GetCurrentWindowPID()
    target_window_pid := GetWindowToPasteIn()
    initialize(target_window_pid, Onepassword_window_pid)
    PastePassword(Onepassword_window_pid, target_window_pid)
    return
}

; --------------- Password and Onetime password -----------------------
^+ß:: ; Ctrl + Shift + ß
^+ü:: ; Ctrl + Shift + ü
{
    Onepassword_window_pid := GetCurrentWindowPID()
    target_window_pid := GetWindowToPasteIn()
    initialize(target_window_pid, Onepassword_window_pid)
    PastePasswordAndOneTimePassword(Onepassword_window_pid, target_window_pid)
    return
}

; --------------- Onetime password only -------------------------------
^':: ; Ctrl + '
^ä:: ; Ctrl + ä
{
    Onepassword_window_pid := GetCurrentWindowPID()
    target_window_pid := GetWindowToPasteIn()
    initialize(target_window_pid, Onepassword_window_pid)
    PasteOneTimePassword(Onepassword_window_pid, target_window_pid)
    return
}

; --------------- Paste username only ---------------------------------
^p:: ; Ctrl + p
{
    Onepassword_window_pid := GetCurrentWindowPID()
    target_window_pid := GetWindowToPasteIn()
    initialize(target_window_pid, Onepassword_window_pid)
    PasteUserName(Onepassword_window_pid, target_window_pid)
    return
}

; --------------- Functions -------------------------------------------
initialize(target_window_pid, Onepassword_window_pid)
{
    QuitIfNotCalledFrom1Password(Onepassword_window_pid)
    QuitIfTargetNotFound(target_window_pid)
}

QuitIfNotCalledFrom1Password(Onepassword_window_pid)
{
    if (WindowIs1Password(Onepassword_window_pid) = false)
    {
        Exit
    }
}

QuitIfTargetNotFound(target_window_pid)
{
    if target_window_pid = ""
    {
        MsgBox("Target window not found")
        Exit
    }
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

WindowTitleIs1PasswordSchnellzugriff(window_title)
{
    if window_title ~= ".*Schnellzugriff.*1Password.*"
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
    source_title := WinGetTitle("ahk_pid " Onepassword_window_pid)
    Send "^c" ; Ctrl + c to copy username
    Sleep 200 ; Wait for pop-up to disappear and re-focus previous window
    WinActivate("ahk_pid " target_window_pid)
    Sleep 300 ; Wait for pop-up to disappear and re-focus previous window
    SetKeyDelay(100)
    Send "{Raw}" A_Clipboard ; Paste pw to focused field
    A_Clipboard := "" ; Empty clipboard
    Send "{Tab}"
    Sleep 500
    Refocus1Password(source_title, Onepassword_window_pid)
}

PastePassword(Onepassword_window_pid, target_window_pid)
{
    Sleep 200
    Send "^+c" ; Ctrl + Shift + c to copy password
    Sleep 200 ; Wait for pop-up to disappear and re-focus previous window
    WinActivate("ahk_pid " target_window_pid)
    Sleep 300 ; Wait for pop-up to disappear and re-focus previous window
    SetKeyDelay(100)
    Send "{Raw}" A_Clipboard ; Paste pw to focused field
    A_Clipboard := "" ; Empty clipboard
}

PasteOneTimePassword(Onepassword_window_pid, target_window_pid)
{
    Sleep 200
    Send "^!c" ; Ctrl + Alt + c to copy one time password
    Sleep 200 ; Wait for pop-up to disappear and re-focus previous window
    WinActivate("ahk_pid " target_window_pid)
    Sleep 300 ; Wait for pop-up to disappear and re-focus previous window
    SetKeyDelay(100)
    Send "{Raw}" A_Clipboard ; Paste pw to focused field
    A_Clipboard := "" ; Empty clipboard
}

PastePasswordAndOneTimePassword(Onepassword_window_pid, target_window_pid)
{
    source_title := WinGetTitle("ahk_pid " Onepassword_window_pid)
    Send "^+c" ; Ctrl + Shift + c to copy password
    Sleep 500
    Password := A_Clipboard
    Refocus1Password(source_title, Onepassword_window_pid)
    Sleep 100
    Send "^!c" ; Ctrl + Alt + c to copy one time password
    Sleep 500
    PasswordAndOneTimePassword := Password . A_Clipboard
    WinActivate("ahk_pid " target_window_pid)
    Sleep 100 ; Wait for pop-up to disappear and re-focus previous window
    SetKeyDelay(100)
    Send "{Raw}" PasswordAndOneTimePassword ; Paste pw to focused field
    A_Clipboard := "" ; Empty clipboard
}

Refocus1Password(source_title, Onepassword_window_pid)
{
    if WindowTitleIs1PasswordSchnellzugriff(source_title) = true
    {
        Send "{Control down}{Shift down}"
        Send "{Space}"
        Send "{Control up}{Shift up}"
    } else {
        WinActivate("ahk_pid " Onepassword_window_pid)
    }
}

GetWindowToPasteIn()
{
    list := ""
    list := WinGetList()
    Loop
    {
        this_id := list[A_Index]

        if not WinExist("ahk_id " this_id)
            continue

        title := WinGetTitle("ahk_id " this_id)

        FoundPos := InStr(title, "1Password")
        if (FoundPos = 0) and (title != "")
        {
            this_pid := WinGetPID("ahk_id" this_id)
            return this_pid
        }
    }
}