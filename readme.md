# IFS RD VAT Service - Business Guide

## What This Does
Automatically validates Thai tax registration numbers and pulls official company data directly from the Revenue Department. When you enter a tax ID, the system fetches real company details and fills them into your Business Central contacts—no manual typing needed.

## Why Use This
- **Accuracy**: Get official data straight from the government source
- **Speed**: One click replaces manual address entry
- **Compliance**: Ensure tax ID validity for business transactions
- **Consistency**: Standardized address formatting across all contacts

## How to Use

### Basic Validation
1. Open any Contact card in Business Central
2. Find the "RD VAT Service" section
3. Click "Validate Contact Data from RD"
4. The system automatically:
   - Verifies the tax ID format
   - Calls the Revenue Department service
   - Updates contact fields with official data

### What Gets Updated
| Field | Source Data |
|-------|-------------|
| **Name** | Official company name |
| **Address** | Building, room, floor, village, house number |
| **Address 2** | Sub-district (Tambon/Kwaeng) |
| **City** | District (Amphoe/Khet) |
| **County** | Province |
| **Post Code** | Postal code |

### Address Assembly Logic
The system intelligently combines multiple address components:
- **Address 1**: Building name + Room + Floor + Village + House number + Moo + Soi + Street
- **Address 2**: Sub-district name
- **City**: District name
- **Province**: Province name (with Bangkok special handling)

### Setup Options
Access **IFS RD VAT Service Setup** to customize:
- Display prefixes for address components (e.g., "ถนน" for streets)
- Exclude certain provinces from prefix display
- Enable/disable update notifications

## Business Benefits
- **Data Quality**: Eliminate address typos and formatting inconsistencies
- **Time Savings**: Reduce manual data entry by 80%+
- **Audit Trail**: Track when and who updated contact information
- **Bangkok Smart Formatting**: Automatically uses เขต/แขวง instead of อำเภอ/ตำบล

## Limitations
- Requires internet connection to Revenue Department service
- Only works with valid Thai tax registration numbers
- Some fields may be empty if not available in government records
- Service availability depends on external system uptime

## Quick Start Example
```al
// Validate a contact programmatically
IFSRDVATService: Codeunit "IFS RD VAT Service";
ContactRec: Record Contact;

IFSRDVATService.SetVATID('1234567890123');
if IFSRDVATService.CheckVatOnce() then begin
    IFSRDVATService.ValidateContactDatafromRD(ContactRec);
    Message('Contact updated with official data');
end;
```

**Bottom line**: Turn tax ID verification into automatic, accurate contact data population—reliable and fast.
