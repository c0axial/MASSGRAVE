# KMS38

## Work In Progress
This version of the document is merely a draft.
Information here may be innacurate, incomplete or missing.

## Description
**KMS38** is a method of activating Windows 10 in which a valid
GenuineAuthorization ticket is created and applied using system tools, mimicking
the KMS Windows 7/8/8.1/10 to 10 upgrade process.

The difference between this method and Digital License is that it applies only
to editions available through Volume licensing (utilizing KMS) and can activate
more uncommon editions such as Windows 10 EnterpriseS (LTSB / LTSC)

It's an activation method capable of activating the system ("only") up until the
January of 2038 due to the [Year 2038 Problem][1].

Despite being similar to the Digital License method it has many differences, one
of which being it can be easily detected in the system and through remote
administration tools.

## Discovery
The method was discovered in October 2018 by Anonymous.

It was based on an error in which a GenuineAuthorization ticket generated on
Windows 10 EnterpriseG and applied on a Windows 10 Pro system would activate the
system for much longer than would be considered normal entirely without
connecting to a KMS server.

## Algorithm
The algorithm, similarly to Digital License, relies on the system tool
**GatherOsState** (Gather Downlevel OS Activation State) utilizing it to
generate a GenuineAuthorization ticket but (unlike Digital License) with a
different field signifying the date on which the previous systems' KMS
activation was meant to expire. The field, if manipulated can yield activation
up until INTEGER\_MAX seconds from the beggining of the Epoch, which is 1st
January 2038 around 03:14:07 UTC.

## Possible Approaches
Identical as in the Digital License method.

## Implementations
This is a list of notable implementation of this method.

(If you wish to report any additional ones, follow the contact info in the main README)

### HWIDGEN (by s1ave77)
The first publicly available implementation of the KMS38 method.

Frontend for the SLC substitution method. Utilizes SLShim v6.0 and multiple gatherosstate executables.

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
A collection of scripts and tools made for activating Microsoft products. Has (currently) the most complete and the most refined implementation of the KMS38 method.

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
### WIP
> Can be detected by looking for abnormal quantities of error [0xC004F074](2) and similar ones in the event log.
> Also, the activation expiry date can be checked for abnormalities (>180 KMS activation days left) with `slmgr.vbs -xpr` (Not suitable for scripts, use WMI)

[1]: https://en.wikipedia.org/wiki/Year_2038_Problem
[2]: http://errorco.de/win32/slerror-h/sl_e_vl_binding_service_unavailable/0xc004f074/