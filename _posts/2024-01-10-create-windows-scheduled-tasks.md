---
layout: post
title: Windows scheduled tasks
date: 2024-01-10 23:20 +0300
categories: [automation]
tags: [scheduled-tasks, windows]
---

sometimes you wanna automate a process like backing up a folder or cleaning up the desktop or some other thing, to do that you can schedule a task to be executed by windows task scheduler.
 
on linux you can do the same thru either a cron job or airflow.

## thru powershell 7


```powershell
Register-ScheduledTask -Action <ACTION U WANNA DO> -Trigger <TRIGGER> -TaskName <TASK NAME>
```

- Action: is the action, for example execute a script
- Trigger: do this action daily @ 12:00AM
- TaskName: give it a meaningful name

example: 

```powershell
Register-ScheduledTask -Action New-ScheduledTaskAction -Execute 'powershell.exe' -Argument "-File .\backup-notes.ps1" -Trigger New-ScheduledTaskTrigger -Daily -At 12:00AM -TaskName "BackUpNotesToGitTask"
```

as you can see this is a monstrosity to type, good thing you can use variables xD

```powershell
$action = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument "-File .\backup-notes.ps1"
$trigger = New-ScheduledTaskTrigger -Daily -At 12:00AM 
Register-ScheduledTask -Action $action -Trigger $trigger -TaskName "BackUpNotesToGitTask"
```

this is simpler and you can make a script outta it.


## thru the gui

I'm gonna create a task that would run an exe that i've written in rust,  which will clean development dependencies for a given directory.

_be careful what you run!_

- open it from start
  - ![step-1](/assets/images/windows-scheduler/CWST-gui.png)
- create Task
  - ![step-2](/assets/images/windows-scheduler/CWST-gui-1.png)
- Actions -> New
  - ![step-3](/assets/images/windows-scheduler/CWST-gui-2.png)
  - ![step-4](/assets/images/windows-scheduler/CWST-gui-3.png)
  - Browse to your *exe* or *script* u wanna run and give it what argument it needs, in this case just "E:\development\front-end" _node-modules gotta go man!_
    - ![step-5](/assets/images/windows-scheduler/CWST-gui-4.png)
  - give it a scheule and click ok _Daily is bad for this, unless u like to keep running `npm i`_
    - ![step-6](/assets/images/windows-scheduler/CWST-gui-5.png)

- there are the 2 tasks we created, the first from the command line and the other from the gui
![step-7](/assets/images/windows-scheduler/CWST-gui-6.png)
- at the defined time the job will run or u can click run
![step-8](/assets/images/windows-scheduler/CWST-gui-7.png)


--- 

## powershell script to backup

> what this does is: 
1. get the current path this was executed from
1.  sets the execution policy,
1. goes to the path my obsidian library lives in
1. pushes the code to github
1. sets the location to the directory it was executed from
1. on error it's supposed to log it into a file in an adjacent folder

```powershell
$errorLog = "C:\Windows Tools\myUtilities\ToolLogs\BackUpNotes.txt"
$currentLocation = Get-Location

try {
  Set-ExecutionPolicy RemoteSigned -Scope Process -Force
  Set-Location -Path "$env:USERPROFILE\notes\crimson_library"
  
  git add -A
  git commit -m "From Task Schedular"
  git push

}
catch {
   $_ | Out-File -FilePath $errorLog -Append
}
finally {
  Set-Location -Path $currentLocation
}


```


