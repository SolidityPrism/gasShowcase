# Gas Optimization Playground - Benchmark & Practice

⚠️ **DISCLAIMER**: This repository contains **deliberately unoptimized smart contracts**. They are designed for educational purposes, gas auditing practice, and benchmarking optimization tools. **DO NOT USE THIS CODE IN PRODUCTION** without heavy refactoring.

## 📖 Overview

This ecosystem simulates a gas-heavy DeFi scenario consisting of three interacting contracts:
1.  **`PlayerRegistry.sol`**: A storage-heavy contract managing user data (Structs & Mappings) with redundant logic.
2.  **`GameLogic.sol`**: A logic-heavy contract iterating over arrays and performing expensive external calls.
3.  **`MathVault.sol`**: A calculation contract demonstrating arithmetic overheads, nested loops, and inefficient math operations.

The code contains a mix of **storage inefficiencies**, **expensive loop patterns**, **tautological checks**, and **suboptimal arithmetic** ranging from easy to hard to detect.

---

## 🏆 Optimization Classification & Difficulty

This table categorizes findings based on **Impact** (Potential Gas Savings) and **Detection Difficulty** (how hard it is for an automated tool or a human to spot it).

| Contract | Optimization Opportunity | Impact (Gas) | Detection Difficulty | Type |
| :--- | :--- | :--- | :--- | :--- |
| **GameLogic** | **External Call in Loop** | 🟢 **High** (~22k) | 🟢 **Easy** | Architectural |
| **PlayerRegistry** | **Struct Packing (3 slots -> 2)** | 🟢 **High** (~20k) | 🔴 **Hard** | Storage Layout |
| **PlayerRegistry** | **Redundant Storage (Wallet)** | 🟢 **High** (~22k) | 🟡 **Medium** | Data Model |
| **MathVault** | **Storage Read in Nested Loop** | 🟢 **High** (~2.5k) | 🟡 **Medium** | Caching |
| **PlayerRegistry** | **Redundant State Check (Keccak)** | 🟡 **Medium** (~2k) | 🟡 **Medium** | Logic / Tautology |
| **GameLogic** | **Uncached Array Length (Memory)** | 🟡 **Medium** (~2k) | 🟡 **Medium** | Caching |
| **MathVault** | **Storage Write in Loop** | 🟡 **Medium** (~800) | 🟢 **Easy** | Storage |
| **MathVault** | **Bit Shift vs Division (/ 2)** | 🔵 **Low** (~2) | 🟢 **Easy** | Arithmetic |
| **All** | **Unchecked Arithmetic** | 🔵 **Low** (~50-100) | 🟢 **Easy** | Arithmetic |

*   **🟢 High Impact:** Saves significantly on execution cost (Storage writes, External calls) or Deployment cost.
*   **🟡 Medium Impact:** Visible savings on loops or frequent operations (Storage reads, Memory).
*   **🔵 Low Impact:** Micro-optimizations (Opcode replacements, Stack operations).

---

## 🔍 Detailed Analysis

### 🚀 HIGH IMPACT (Big Savings)

#### 1. External Calls in Loop
*   **Contract:** `GameLogic.sol`
*   **Function:** `processGameBatch()`
*   **Description:** The function loops through an array and calls `registry.updateScore()` at *every* iteration. This prevents batching and incurs base call overhead (min 100 gas + cold access) for every iteration.
*   **Optimization:** Implement a `batchUpdateScore` function in the Registry to perform a single external call with an array of data.

#### 2. Unoptimized Struct Packing
*   **Contract:** `PlayerRegistry.sol`
*   **Struct:** `Player`
*   **Difficulty:** 🔴 Hard
*   **Description:** The struct layout is `bool` (1 byte), `uint256` (32 bytes), `address` (20 bytes). Because `uint256` requires a full slot, this layout takes **3 storage slots**.
*   **Optimization:** Reorder to `bool` + `address` (21 bytes total < 32 bytes) followed by `uint256`.
*   **Gain:** Saves **1 SSTORE (20,000 gas)** per new user registration.

#### 3. Redundant Storage (Data Model)
*   **Contract:** `PlayerRegistry.sol`
*   **Struct:** `Player`
*   **Description:** The struct contains `address wallet`. However, this struct is stored in a mapping: `mapping(address => Player)`. Storing the address inside the value is redundant as it is already the key.
*   **Optimization:** Remove the `wallet` field from the struct.
*   **Gain:** Saves **1 Storage Slot (20,000 gas)** per user.

#### 4. Nested Loop Storage Access
*   **Contract:** `MathVault.sol`
*   **Function:** `calculateHeavyMath()`
*   **Description:** The variable `globalMultiplier` (State Variable) is read inside a double nested loop (`5 * 5 = 25` iterations).
*   **Optimization:** Cache the variable in memory (`uint256 cachedMultiplier = globalMultiplier;`) before the loops.
*   **Gain:** Saves `100 gas` (Warm SLOAD) x 25 Iterations = **~2,500 gas**.

---

### ⚠️ MEDIUM IMPACT (Cumulative Savings)

#### 5. Dynamic Keccak256 Calculation (Redundant Logic)
*   **Contract:** `PlayerRegistry.sol`
*   **Function:** `register()`
*   **Description:** `require(keccak256(bytes(gameName)) == ...)` checks a state variable against its initial value. Since `gameName` is never modified, this check is a tautology (always true) and wastes gas on hashing and storage reading.
*   **Optimization:** Remove the check entirely or mark `gameName` as constant.
*   **Gain:** Saves ~2000+ gas.

#### 6. Reading State Variables in Loops
*   **Contract:** `GameLogic.sol`
*   **Function:** `processGameBatch()`
*   **Description:** The check `i >= batchSize` reads `batchSize` from storage at every iteration.
*   **Optimization:** Cache `batchSize` in a local stack variable.
*   **Gain:** Saves **100 gas per iteration**.

#### 7. Uncached Array Length
*   **Contract:** `GameLogic.sol`
*   **Function:** `processGameBatch()`
*   **Description:** The loop condition `i < _winners.length` reads the array length from memory/calldata at every iteration. While cheaper than storage, it still costs gas (MLOAD/Calldata load).
*   **Optimization:** Cache the length in a local stack variable (`uint256 len = _winners.length`).

---

### ⚡ LOW IMPACT (Micro-Optimizations)

#### 8. Division vs Bit Shift
*   **Contract:** `MathVault.sol`
*   **Function:** `quickDiv()`
*   **Description:** `amount / 2` uses the `DIV` opcode (5 gas).
*   **Optimization:** Use Bit Shift `SHR` (`amount >> 1`) which costs 3 gas.
*   **Gain:** ~2 gas per operation.

#### 9. Unchecked Arithmetic (Solidity 0.8+)
*   **Contract:** All
*   **Description:** Since Solidity 0.8.0, arithmetic operations check for overflow/underflow by default, adding gas overhead.
*   **Optimization:** Use `unchecked { ++i; }` for loop increments where overflow is impossible.
*   **Gain:** ~30-100 gas depending on loop size.

---

## 🛠 Setup & Benchmarking

To analyze gas usage and run these contracts:

1. **Clone the repo**
2. **Install Dependencies**
   ```bash
   npm install
   ```
