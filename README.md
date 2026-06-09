# 0xAnalyst/webshells

ASPX webshells written for EDR and YARA detection testing. Each shell targets a specific telemetry source or detection gap. **For use in isolated lab environments only.**

![Defensive Research](https://img.shields.io/badge/purpose-defensive%20research-blue)
![Platform](https://img.shields.io/badge/platform-IIS%20%2F%20ASPX-lightgrey)
![Language](https://img.shields.io/badge/language-.NET%20%2F%20ASPX-purple)

---

## Repository structure

```
webshells/
├── README.md
├── existing/
│   ├── Poweraspx.aspx
│   └── CreateProcessWebshell.aspx
├── execution-evasion/
│   ├── README.md
│   ├── COMShell.aspx
│   ├── WMIShell.aspx
│   └── MSBuildShell.aspx
├── obfuscation/
│   ├── README.md
│   ├── XorShell.aspx
│   └── RoslynShell.aspx
├── injection/
│   ├── README.md
│   ├── ReflectivePEShell.aspx
│   └── SyscallShell.aspx
├── network-c2/
│   ├── README.md
│   ├── DoHShell.aspx
│   └── WebSocketShell.aspx
└── defense-evasion/
    ├── README.md
    ├── ETWPatchShell.aspx
    └── AMSIPatchShell.aspx
```

---

## Shells

### Original

| File | Target | ATT&CK | Description |
|------|--------|--------|-------------|
| `Poweraspx.aspx` | EDR + SIEM | T1059.001 | PowerShell execution via ASPX. Tests w3wp.exe → powershell.exe parent-chain rules. |
| `CreateProcessWebshell.aspx` | EDR | T1059, T1106 | P/Invoke kernel32!CreateProcess with hardcoded System32 path. Tests DllImport and direct process creation signatures. |

---

### Execution evasion — `execution-evasion/`

| File | Target | ATT&CK | Description |
|------|--------|--------|-------------|
| `COMShell.aspx` | EDR + SIEM | T1559.001 | WScript.Shell via late-bind COM. Breaks the w3wp.exe process chain — no cmd.exe spawn. |
| `WMIShell.aspx` | EDR + SIEM | T1047 | Win32_Process.Create. Fully detached, parent PID is WMI not IIS. Tests parent-chain correlation rules. |
| `MSBuildShell.aspx` | EDR | T1127.001 | Drops and executes a .proj file via MSBuild.exe. Tests LOLBin and trusted binary abuse detection. |

---

### Obfuscation — `obfuscation/`

| File | Target | ATT&CK | Description |
|------|--------|--------|-------------|
| `XorShell.aspx` | EDR | T1027 | XOR + base64 runtime decode. Defeats static YARA string rules — forces behavioral or memory-scan detection. |
| `RoslynShell.aspx` | EDR | T1027.010 | CSharpScript.EvaluateAsync — compiles arbitrary C# at runtime. No disk write, no static signature possible. |

---

### Process injection — `injection/`

| File | Target | ATT&CK | Description |
|------|--------|--------|-------------|
| `ReflectivePEShell.aspx` | EDR | T1620 | In-memory PE load without LoadLibrary or touching disk. Tests NtProtectVirtualMemory memory scanning coverage. |
| `SyscallShell.aspx` | EDR | T1055 | Direct NtAllocateVirtualMemory syscall stubs. Bypasses user-mode EDR hooks — tests kernel-level telemetry. |

---

### Network / C2 — `network-c2/`

| File | Target | ATT&CK | Description |
|------|--------|--------|-------------|
| `DoHShell.aspx` | SIEM | T1071.004 | Commands encoded in DNS-over-HTTPS queries on port 443. Tests SIEM coverage beyond plain port-53 DNS rules. |
| `WebSocketShell.aspx` | SIEM | T1071.001 | Persistent bidirectional WebSocket channel. Tests SIEM detection of long-lived connections from w3wp.exe. |

---

### Defense evasion — `defense-evasion/`

| File | Target | ATT&CK | Description |
|------|--------|--------|-------------|
| `ETWPatchShell.aspx` | EDR | T1562.006 | EtwEventWrite nop-patch — blinds ETW-based EDR telemetry in-process. Tests tamper-protection coverage. |
| `AMSIPatchShell.aspx` | EDR | T1562.001 | AmsiScanBuffer patch — disables AMSI scanning in-process. Tests AMSI tamper detection rules. |

---

## Detection coverage map

| Telemetry source | Shells that test it |
|-----------------|---------------------|
| Process creation (Sysmon EID 1) | Poweraspx, CreateProcessWebshell, WMIShell, MSBuildShell |
| Parent process chain | Poweraspx, COMShell, WMIShell |
| ETW / .NET runtime events | ETWPatchShell, RoslynShell, SyscallShell |
| AMSI scan events | AMSIPatchShell, RoslynShell |
| LOLBin execution | MSBuildShell |
| Network / DNS logs | DoHShell, WebSocketShell |
| Memory scanning | ReflectivePEShell, SyscallShell |
| Static YARA (file) | XorShell, RoslynShell, CreateProcessWebshell |

---

## Lab setup

- Isolated VM — no internet access
- IIS with .NET 4.x application pool
- EDR running in audit/detect-only mode with telemetry logging enabled
- Log forwarding to a test SIEM instance
- Snapshot the VM before each test run; revert after

---

## References

- [MITRE ATT&CK — Web Shell (T1505.003)](https://attack.mitre.org/techniques/T1505/003/)
- [MITRE ATT&CK — Command and Scripting Interpreter (T1059)](https://attack.mitre.org/techniques/T1059/)
- [NSA/CISA Advisory — Web Shell Malware](https://media.defense.gov/2020/Jun/09/2002313081/-1/-1/0/CSI-DETECT-AND-PREVENT-WEB-SHELL-MALWARE-20200422.PDF)

---

> **Disclaimer:** These shells are written for authorized security testing and EDR/SIEM validation in controlled lab environments. Unauthorized use against systems you do not own or have explicit permission to test is illegal.

---

### Updates from technique table

#### Execution evasion additions

| File | Native API | ATT&CK | Evasion | YARA/EDR Bypass |
|------|-----------|--------|---------|-----------------|
| `CreateProcess_Dynamic.aspx` | `kernel32!CreateProcessA` | T1106 · T1027 | Dynamic P/Invoke via GetProcAddress, XOR-obfuscated strings | No static DllImport, no cleartext API names |
| `ShellExecuteEx_Runas.aspx` | `shell32!ShellExecuteEx` | T1548.002 · T1106 | runas verb, SW_HIDE, minimal command-line logging | Avoids CreateProcess logging, runs as different user context |
| `CreateProcessAsUser_Impersonate.aspx` | `advapi32!CreateProcessAsUser` | T1134.001 · T1055 | Impersonates logged-on user token, CREATE_SUSPENDED flag | Breaks process lineage detection, no parent-child relation |

#### Injection additions

| File | Native API | ATT&CK | Evasion | YARA/EDR Bypass |
|------|-----------|--------|---------|-----------------|
| `WinExec_Syscall.aspx` | `ntdll!NtCreateProcess` (syscall) | T1055 · T1562.006 | Direct syscall via Heaven's Gate stub, no ntdll in memory | Bypasses EDR user-land hooks completely |

#### Obfuscation additions

| File | Native API | ATT&CK | Evasion | YARA/EDR Bypass |
|------|-----------|--------|---------|-----------------|
| `InMemory_Assembly_XOR.aspx` | `System.Diagnostics.Process` (reflected) | T1027 · T1620 | XOR-encoded .NET assembly loaded via Assembly.Load | No file on disk, static analysis bypass via encoding |

#### Defense evasion additions

| File | Native API | ATT&CK | Evasion | YARA/EDR Bypass |
|------|-----------|--------|---------|-----------------|
| `NtCreateProcess_Unhook.aspx` | `ntdll!NtCreateProcess` | T1562.001 · T1055 | Fresh ntdll mapped from disk → invoke clean syscall | Removes EDR hooks from ntdll before invocation |
| `WMI_Com_ETW_AMSI_Patch.aspx` | `Win32_Process.Create` via COM | T1562.001 · T1562.006 · T1047 | In-process AMSI + ETW patching before WMI call | Disables script scanning and ETW logging |
