# Smart Inventory System — 8086 Assembly

A console-based inventory management system written entirely in **x86 (8086) Assembly**, targeting the DOS environment. Built as a low-level systems programming project, it manages products and suppliers through a role-based access control system with XOR-encrypted password authentication.

---

## Features

**Role-Based Access (3 tiers)**
- **Admin** — Full control: add products, restock, record sales, manage suppliers, view reports
- **Supplier** — Restricted access: view and restock only their own assigned products
- **User (Read-Only)** — Browse all products and search by ID or name

**Product Management**
- Add new products (ID, name, category, price, quantity, supplier link)
- View all products in a formatted table
- Restock and sell products with overflow protection
- Search by product ID or name
- Low stock alert — flags items running low
- Total inventory value calculation (with 32-bit accumulation for large values)

**Supplier Management**
- Add and view suppliers with contact info and active/inactive status
- Supplier ownership enforcement (suppliers can only restock their own products)

**Security**
- Passwords are XOR-encrypted in memory at startup (key `0xAA`)
- Input is compared against the encrypted form — plaintext is never held in memory during checks

---

## Technical Details

| Property | Value |
|---|---|
| Architecture | x86 / 8086 |
| Memory Model | SMALL |
| Assembler | MASM (Microsoft Macro Assembler) |
| OS Target | MS-DOS / DOSBox |
| BIOS/DOS Interrupts | `INT 21H` (DOS), `INT 10H` (BIOS video) |
| Max Products | 10 |
| Max Suppliers | 5 |

**Macros defined:**
- `DISPLAY_STR` — prints a `$`-terminated string via DOS INT 21H/AH=09H
- `WZ_NEWLINE` — outputs CR+LF
- `PRINT_CHAR` — outputs a single character via AH=02H
- `CLEAR_SCREEN` — clears the console using BIOS INT 10H scroll (AH=06H)

---

## Getting Started

### Requirements

- [DOSBox](https://www.dosbox.com/) (recommended for modern systems)
- [MASM](https://www.masm32.com/) or any compatible 16-bit assembler (e.g., TASM)
- DOS `LINK` utility or equivalent

### Build & Run

```bash
# Assemble
MASM mycode.asm;

# Link
LINK mycode.obj;

# Run inside DOSBox
mycode.exe
```

Or using a one-step assembler shortcut if your toolchain supports it:

```bash
ML mycode.asm
```

### Default Credentials

| Role | Password |
|---|---|
| Admin | `admin` |
| Supplier | `supp` |

> Passwords are XOR-encrypted in memory immediately on startup. Do not store sensitive data using this scheme in production.

---

## Project Structure

```
mycode.asm          # Entire project — single self-contained assembly source file
```

The project is intentionally a single-file program, consistent with a DOS-era assembly style where the `.MODEL SMALL` memory model keeps code and data within one 64 KB segment each.

---

## Limitations

- Data is **not persistent** — all inventory and supplier records reset when the program exits (no file I/O)
- Fixed capacity: 10 products, 5 suppliers (compile-time `EQU` constants)
- Designed for 16-bit DOS only; will not run natively on 64-bit Windows/Linux without an emulator
- Password security is minimal (XOR obfuscation, not encryption)

---

## Purpose

This project was built as a **computer organization / assembly language course project** to demonstrate:

- Low-level memory management and register manipulation
- DOS interrupt-based I/O
- Macro definitions and structured procedure calls in assembly
- Role-based program flow using jump tables
- Basic in-memory data obfuscation

---

## License

This project is released as-is for educational and archival purposes. No active maintenance is planned.
