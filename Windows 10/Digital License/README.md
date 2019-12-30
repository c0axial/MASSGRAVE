# Digital License / HWID
## Work In Progress
This version of the document is merely a draft.
Information here may be innacurate, incomplete or missing.

## Description
[**Digital License**][1] (or **HWID**) is a method of activating Windows 10 in which
a valid GenuineAuthorization ticket (*GenuineTicket.xml*) is created and applied
on non-genuine systems, mimicking the Windows 7/8/8.1/10 to 10 upgrade process'
licensing status transfer.
It is a permanent activation method; It does not require
renewal or further use of any tools to maintain. The only way for activation to
be invalidated is through a hardware change.

The activation itself is linked to a specific machine through an unique
identifier known as the *Hardware ID*. (hence the name of the method)

Through the use of a Microsoft account, the activation can be transfered even
through hardware changes and is permanently tied to the user.

This method is also widely known as "Digital License generation without KMS or
predecessor install/upgrade".

## Discovery
The method was discovered in January of 2018 by Anonymous and mspaintmsi.
The first (proof of concept) tool for obtaining activation through this method
was developed by Anonymous under the name *HWIDWizard* and was used as a base
for s1ave77's *HWIDGEN* - the first publicly available tool for this method.

The first methods before public release used a KMS activated system and a 
modified version of **GatherOsState** and yielded activation status for retail
systems.

## Algorithm
The most implementations rely on the system tool **GatherOsState.exe** (Gather
Downlevel OS Activation State) utilizing it to generate a GenuineAuthorization
ticket. The most common approach is utilizing a modified **slc.dll** library
(Software Licensing Client) and manipulating GatherOsState's internal state to
produce a genuine ticket.

The generated ticket can later be applied using ClipUp (Client License Platform
migration tool). ClipUp sends the ticket to Microsoft servers and returns a
valid Digital License file. The servers mark the machine's hardware ID and the
account (if applicable) as activated.

The command used to apply the ticket is as follows:
```
ClipUp.exe -v -o -altto *Ticket Directory*
```
or alternatively by placing it in the
`%ProgramData%\Microsoft\Windows\ClipSVC\GenuineTicket` directory. Then you can
either restart the service or issue thie following command:
```
ClipUp.exe -v -o
```

Additional measures need be taken for the process to work. This includes
enabling:
 * Windows Update
 * ClipSvc
 * LicensingService

## Possible Approaches
### SLC Substitution
Because of GatherOsState utilizing [run-time dynamic linking](2) to load the 
Software Licensing library (slc.dll) the library file can be substituted with
a modified one by placing it in the same folder as the GatherOsState executable
and appropriately renaming it.

The only known implementation of this approach is loosely based on vyvojar's 
slshim ([GitHub](3)) and still uses its name.

### Memory Hacking
The memory hacking approach creates a suspended GatherOsState process by simply
running the file through the CreateProcess function. The implementation then
replaces certain memory ranges in the process for it to create a valid ticket
with the desired information.

All known implementations are AV-detected.

### Static Executable Editing
This rather uncommon method is similar to the memory hacking approach, but
instead of running the process, all changes are performed on the gatherosstate
executable. This approach is not often used, because of high risk of detection
by preventative antiviruses and invalid ticket generation for some editions of
Windows 10.

### GenuineAuthorization XML Generator
This approach involves recreating the ticket generation process in a piece of
software, which could detect all required information and successfully generate
a hardware ID. The difficulties in creating such software is obtaining the
cryptographic keys used by sppsvc and/or gatherosstate and reverse engineering
the algorithm responsible for generating the hardware ID.

There are no known implementations of this method.

## Implementations
This is a list of notable implementations of this method.

(If you wish to report any additional ones, follow the contact info in the main README)

### HWIDWizard (by Anonymous, Proof of Concept)
A proof of concept tool written for the purpose of demonstrating the activation
method. Written by one of the authors of the method.

Disadvantages:
 * Not verbose.
 * Purely demonstrational.

#### Programming Language
AutoHotkey, C (SLShim)

#### Code
Open Source, Available in the "Deprecated Implementations" folder in versions 1.0 and 1.1.1

### HWIDGEN (by s1ave77)
The first publicly available implementation of the Digital License
activation method as well as the very similar KMS38 method. Utilizes
code fragments of HWIDWizard.

Frontend for the SLC substitution method. Utilizes SLShim v6.0 and multiple
gatherosstate executables.

There are some disadvantages to this tool, such as:
 * Not every edition is supported.
 * Not very verbose; Errors are hard to diagnose.
 * Development has been discontinued. (?)

#### Source
AiOWARES Forum

#### Programming Language
AutoHotkey, C (SLShim)

#### Code
Closed source. Released as an UPX-packed AHK to EXE executable.

### Microsoft Activation Scripts (by WindowsAddict)
A collection of scripts and tools made for activating Microsoft products. Has
(currently) the most complete and the most refined implementation of the Digital
License method.

Advantages:
 * Verbose.
 * Easy to use.

#### Source
Nsane Forums

#### Programming Language
Batch, PowerShell, C (SLShim)

#### Code
Open Source, Script available in the MASSGRAVE group's repositories.

## Detection
The use of this method has been proved impossible to detect. (Especially if
transferred via a Microsoft account)
There are no distinctive signs of using this method other than the applied
tickets and some implementations' "leftovers", which can be detected
locally or through remote administration tools.

## Implementation-specific Detection
Known detection methods for specific implementations. If you know of any for
different implementations, report them to any contributor or make a merge
request.

### Detection of HWIDGEN
This implementation does not leave any traces in the system, except for "silent
mode", in which case it will leave an executable which will inform the user that
their copy of the system has been illegally activated.

The warning is added to the registry in the following keys:
 * `HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnceEx`
 * `HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnceEx\0001`

The executable of the warning can be found in the following paths, dependent of
the used activation method (warnk for KMS38 and warnh for HWID):
`%windir%\temp\warnk.exe`
`%windir%\temp\warnh.exe`

[1]: https://support.microsoft.com/en-us/help/12440/windows-10-activate
[2]: https://docs.microsoft.com/en-us/windows/win32/dlls/run-time-dynamic-linking
[3]: https://github.com/vyvojar/slshim