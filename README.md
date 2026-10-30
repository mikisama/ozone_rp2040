# Ozone RP2040

A minimal example showing how to configure SEGGER Ozone for debugging and downloading firmware on the Raspberry Pi RP2040.

## Overview

This project customizes the following Ozone hooks to ensure reliable downloading and target execution on the RP2040:

- `TargetDownload()`
- `AfterTargetReset()`
- `_SetupTarget()`

## Hook Implementations

### `TargetDownload()`
Replaces the default download routine. Downloads `hello_serial.hex` directly instead of the ELF file to prevent HardFault issues during consecutive re-downloads.

### `AfterTargetReset()`
Event handler called after target reset. Detects if the application is a `NO_FLASH` build running in RAM (Entry Point PC at `0x20000000`). If so, it re-downloads the HEX image and invokes `_SetupTarget()`.

### `_SetupTarget()`
Helper function called by `AfterTargetReset()` and `AfterTargetDownload()`. Sets the Program Counter (`PC`) explicitly for `NO_FLASH` builds running from RAM.

## Troubleshooting

1. **HardFault on Second Download**:
   - **Issue**: Re-downloading a FLASH build using `hello_serial.elf` triggers a `HardFault` on the second download.
   - **Fix**: Implemented `TargetDownload()` to use `Exec.Download("$(ProjectDir)/build/hello_serial.hex")`.

2. **RAM / NO_FLASH Builds**:
   - **Issue**: `NO_FLASH` builds running from RAM (`0x20000000`) require explicit PC setup and image re-download upon reset.
   - **Fix**: Handled via `AfterTargetReset()` and `_SetupTarget()`.
