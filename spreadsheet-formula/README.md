# 📊 Advanced Spreadsheet Automations & Data Ops Toolkit

Welcome to my Spreadsheet Toolkit! This repository contains a curated collection of advanced Google Sheets and Microsoft Excel formulas designed to solve real-world data wrangling, string manipulation, and system automation challenges. 

Whether it's parsing DevOps alerting data, creating dynamic lookups, or cleaning text data at scale, these snippets represent efficient, error-proof approaches to spreadsheet operations.

## 🗂 Table of Contents
- [🔍 Lookups & Validations](#-lookups--validations)
- [📝 Text Manipulation & Cleaning](#-text-manipulation--cleaning)
- [📅 Date & Time Operations](#-date--time-operations)
- [🚀 Advanced Arrays & Filtering](#-advanced-arrays--filtering)
- [⚙️ System Alerts & Regex Parsing](#️-system-alerts--regex-parsing)
- [🌐 Cross-Sheet Imports & Analytics](#-cross-sheet-imports--analytics)

---

## 🔍 Lookups & Validations
*Error-proof methods for validating data across multiple sheets and identifying duplicates.*

| Use Case | Formula |
| :--- | :--- |
| **Exact Match Lookup:** Finds specific data in a locked table array | `=VLOOKUP(A2, Sheet1!$A$2:$B$37, 2, 0)` |
| **Safe Lookup:** Standard VLOOKUP but gracefully handles missing data without `#N/A` | `=IFERROR(VLOOKUP(A2, Sheet1!$A$2:$B$37, 2, 0), "No Data")` |
| **Cross-Sheet Exists Check:** Returns "Yes" if a value exists in another sheet, otherwise "No" | `=IF(COUNTIF('Feb-HRList'!$A:$A, B2) > 0, "YES", "No")` |
| **Same-Sheet Exists Check:** Validate if a value exists in column B | `=IF(COUNTIF(B:B, A2) > 0, "Yes", "No")` |
| **Identify Duplicates:** Flags cells that appear more than once (great for Conditional Formatting) | `=COUNTIF(A:A, A1) > 1` |
| **Direct Comparison:** Checks if two columns match perfectly (Returns TRUE/FALSE natively) | `=A1='Jul-AWS-UsersList-24'!B1` |

---

## 📝 Text Manipulation & Cleaning
*Formulas to sanitize, extract, and clean messy strings or structured text arrays.*

| Use Case | Formula |
| :--- | :--- |
| **Extract JSON-like Keys:** Extracts the "owner" name from a structured string (e.g., `{team:it, owner:siraj}`) | `=IFERROR(MID(A1, FIND("own", A1), FIND(",", A1&",", FIND("own", A1)) - FIND("own", A1)), "")` |
| **Remove Domain:** Strips a specific email domain from a cell | `=SUBSTITUTE(A1, "@example.com", "")` |
| **Character Replacement:** Replaces specific strings case-sensitively | `=SUBSTITUTE(A1, "C", "Z")` |
| **Threshold Check:** Extracts the numerical value before a space and checks if >90 (Used for age formatting) | `=VALUE(LEFT(C1, IFERROR(FIND(" ", C1) - 1, LEN(C1)))) > 90` |
| **Clean Double Line Breaks:** Replaces double carriage returns with single ones | `=SUBSTITUTE(A2, CHAR(10)&CHAR(10), CHAR(10))` |
| **Extract Prefix:** Grabs only the first 5 characters of a string | `=LEFT(A1, 5)` |

---

## 📅 Date & Time Operations
*Calculating age, life-cycles, and relative days.*

| Use Case | Formula |
| :--- | :--- |
| **Months Old:** Calculates months elapsed from a target date to today | `=DATEDIF(E2, TODAY(), "M") & " months old"` |
| **Days Old (Dynamic):** Calculates days elapsed relative to today | `=DAYS(TODAY(), F2) & " Days"` |
| **Days Old (Static):** Calculates days elapsed relative to a fixed cutoff date | `=DAYS(DATE(2024, 8, 2), F2) & " Days"` |

---

## 🚀 Advanced Arrays & Filtering
*Techniques to combine, group, and number dynamic data without manual dragging.*

| Use Case | Formula |
| :--- | :--- |
| **Unique Values:** Extracts a de-duplicated array from a messy column | `=UNIQUE(A:A)` |
| **Conditional Join:** Aggregates values matching a condition into a single cell, separated by line breaks | `=TEXTJOIN(CHAR(10), TRUE, FILTER('SA-Key'!$F:$F, 'SA-Key'!$B:$B = B2))` |
| **Comma Separation:** Flattens a column into a single comma-separated string | `=TEXTJOIN(",", TRUE, E2:E55)` |
| **Numbered Array List:** Groups items by an ID, returning a formatted numbered list (`1. Item`) | `=TEXTJOIN(CHAR(10), TRUE, "1. " & FILTER(Sheet1!B:B, Sheet1!A:A = A2))` |
| **Multi-Column Formatting:** Joins corresponding values from multiple columns into `Col C - Col B` format | `=TEXTJOIN(CHAR(10)&CHAR(10), TRUE, FILTER($C:$C & " - " & $B:$B, $A:$A = A2))` |
| **Dynamic Numbering:** Numbers rows sequentially, resetting to 1 if a blank row is encountered | `=ARRAYFORMULA(IF(ISBLANK(B2:B), "", SCAN(0, B2:B, LAMBDA(acc, curr, IF(curr="", 0, acc+1)))))` |

---

## ⚙️ System Alerts & Regex Parsing
*Specifically designed to parse unstructured log data, cloud platforms, and DevOps alerts.*

| Use Case | Formula |
| :--- | :--- |
| **Extract Service Accounts:** Extracts the specific account name right after `serviceAccounts/` | `=REGEXEXTRACT(B2, "serviceAccounts/([^/]+)")` |
| **Prometheus Target Extraction:** Extracts the application name from `[FIRING:X]` Prometheus payloads | `=ARRAYFORMULA(IF(C2:C="", "", REGEXEXTRACT(C2:C, "\[FIRING:\d+\]\s*([\w-]+)")))` |
| **Prometheus Alert Name:** Grabs the specific alert name from an `alertname = ` tag | `=REGEXEXTRACT(C2, "alertname\s*=\s*([\w-]+)")` |

---

## 🌐 Cross-Sheet Imports & Analytics
*Importing real-time remote data between isolated workbooks.*

| Use Case | Formula |
| :--- | :--- |
| **Import Remote Data:** Pulls a live column stream from another external Google Sheet *(Must authorize access first)* | `=IMPORTRANGE("https://docs.google.com/spreadsheets/d/your-sheet-id/edit", "sheet2!E:E")` |
| **Remote Data Analytics:** Directly performs conditional counting on a live remote Sheet without importing it to a tab first | `=COUNTIF(IMPORTRANGE("https://docs.google.com/spreadsheets/d/your-sheet-id/edit", "sheet2!E:E"), "Applied")` |

---
*Created and maintained by a Data & Operations enthusiast. Feel free to use these snippets in your own projects!*